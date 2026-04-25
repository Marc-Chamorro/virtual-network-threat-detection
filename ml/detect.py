#!/usr/bin/env python3
"""
detect.py - Real-time anomaly detection using Isolation Forest - VNTD
======================================================================
Reads Suricata's eve.json from the logwatch Docker container in real time,
processes each event through the EXACT same pipeline as the training notebook,
and scores each window using the pre-trained Isolation Forest model.

Events are buffered in tumbling time windows (default: 30 seconds). At the end
of each window ALL buffered events are scored together, so the time-window
features (flows_to_dest_port_wndw, unique_srcs_to_dest_wndw, ...) are computed
over a meaningful real-world period instead of an arbitrary batch count.

Why time windows instead of event batches?
  With a batch of 50 events that arrive in 50 ms, every event falls inside the
  same 30 s window slot, so flows_to_dest_port_wndw = 50 for all of them -
  identical to a DoS flood.  With a real 30 s window, 50 events across 30 s
  looks like normal traffic, while 10,000 events across 30 s is flagged.

The terminal is split into 4 panels:
  - Top    (~1/3): live events as they arrive
  - Middle (~1/3): anomaly alerts
  - Bottom (~1/6): runtime statistics
  - Bottom (~1/6): AI model information

Usage (called from ml_detect.sh):
    python3 detect.py --container <name> --models <dir> [--threshold <v>] [--window <s>]
"""

# ──────────────────────────────────────────────────────────────────────────────
# IMPORTS
# ──────────────────────────────────────────────────────────────────────────────

import argparse
import curses
import json
import os
import queue
import subprocess
import sys
import threading
import time
import warnings
from pathlib import Path

# Suppress sklearn warnings BEFORE importing sklearn/joblib.
# Without this, messages like "X does not have valid feature names" print to
# stderr and corrupt the curses display.
warnings.filterwarnings("ignore")

import joblib
import numpy as np
import pandas as pd


# ──────────────────────────────────────────────────────────────────────────────
# CONSTANTS
# Copied from the notebook (Steps 0 and 3) - do NOT change without also
# retraining the model in the notebook.
# ──────────────────────────────────────────────────────────────────────────────

# Suricata event types we do NOT want to analyse.
EXCLUDE_TYPES = {"alert"}

EVENT_TYPE_MAP = {
    "flow":     0,
    "dns":      1,
    "http":     2,
    "smtp":     3,
    "anomaly":  4,
    "ssh":      5,
    "tls":      6,
    "fileinfo": 7,
}

PROTO_MAP = {
    "ICMP":      1,
    "TCP":       6,
    "UDP":       17,
    "IPv6-ICMP": 58,
}

DNS_TYPE_MAP = {
    "query":  0,
    "answer": 1,
}

FLOW_STATE_MAP = {
    "closed":      0,
    "established": 1,
    "new":         2,
    "syn_sent":    3,
}

FLOW_REASON_MAP = {
    "fin":     0,
    "rst":     1,
    "timeout": 2,
    "forced":  3,
}

DNS_RCODE_MAP = {
    "NOERROR":  0,
    "NXDOMAIN": 1,
    "REFUSED":  2,
    "SERVFAIL": 3,
}

# ──────────────────────────────────────────────────────────────────────────────
# FEATURE LIST  (notebook Step 6)
# Must match EXACTLY what the model was trained on - same columns, same order.
# ──────────────────────────────────────────────────────────────────────────────

FEATURES = [
    # --- all events ---
    "event_type_num",       # what type of event: flow=0, dns=1, http=2, smtp=3...
    "proto_num",            # network protocol: TCP=6, UDP=17, ICMP=1...
    "src_port",             # source port number
    "dest_port",            # destination port number
    # --- flow events ---
    "flow_state_num",       # connection state
    "flow_reason_num",      # flow termination reason
    "flow_pkts_toserver",   # packets sent to server
    "flow_pkts_toclient",   # packets received from server
    "flow_bytes_toserver",  # bytes sent to server
    "flow_bytes_toclient",  # bytes received from server
    "flow_age",             # how long the connection lasted (seconds)
    # --- derived from flow ---
    "bytes_per_pkt",        # avg bytes per packet (low = scan traffic)
    "pkt_ratio",            # packet asymmetry (high = possible DoS)
    "bytes_ratio",          # byte asymmetry
    # --- TCP flags (flow events only; 0 for UDP/ICMP) ---
    "tcp_syn",              # SYN flag: connection initiation
    "tcp_fin",              # FIN flag: clean connection close
    "tcp_ack",              # ACK flag: acknowledgement
    "tcp_rst",              # RST flag: forced rejection
    # --- HTTP events ---
    "http_status",          # response code: 200, 404, 500...
    "http_length",          # size of the HTTP response body
    # --- DNS events ---
    "dns_type_num",         # 0 = query, 1 = answer
    "dns_rcode_num",        # response code: 0=NOERROR, 1=NXDOMAIN, 2=REFUSED...
    # --- time window features ---
    "flows_to_dest_port_wndw",          # connections to same dest/port in window (DoS)
    "unique_srcs_to_dest_wndw",         # unique source IPs to same dest in window (DDoS)
    "flows_from_src_wndw",              # connections from same source IP in window (brute force)
    "unique_dest_ports_from_src_wndw",  # unique dest ports from same source in window (scan)
]


# ──────────────────────────────────────────────────────────────────────────────
# PIPELINE FUNCTIONS
# Mirror notebook Steps 1, 3, 4a, 4b exactly.
# ──────────────────────────────────────────────────────────────────────────────

def flatten_json(event_dict, parent_key="", sep="_"):
    """
    Recursively flattens a nested dictionary into a flat key=value dict.
    Copied from notebook - Step 1.

    Example:
        {"flow": {"age": 5}}    ->  {"flow_age": 5}
        {"tcp":  {"syn": True}} ->  {"tcp_syn": True}
    """
    items = []
    for key, value in event_dict.items():
        new_key = f"{parent_key}{sep}{key}" if parent_key else key
        if isinstance(value, dict):
            items.extend(flatten_json(value, new_key, sep=sep).items())
        elif isinstance(value, list):
            if len(value) == 0:
                items.append((new_key, None))
            else:
                for index, item in enumerate(value):
                    list_key = f"{new_key}{sep}{index}"
                    if isinstance(item, dict):
                        items.extend(flatten_json(item, list_key, sep=sep).items())
                    else:
                        items.append((list_key, item))
        else:
            items.append((new_key, value))
    return dict(items)


def encode_text_fields(events_df):
    """
    Converts text columns to numbers so the model can read them.
    Copied from notebook - Step 3.

    Boolean TCP flags (tcp_syn, tcp_fin, tcp_ack, tcp_rst) are converted to
    int so absent flags (NaN) become 0 rather than staying as Python booleans,
    matching the notebook's encode_fields behaviour.
    """
    # Event type -> number (unknown types get 99)
    events_df["event_type_num"] = events_df["event_type"].map(EVENT_TYPE_MAP).fillna(99)

    # Network protocol -> number (unknown protocols get 0)
    if "proto" in events_df.columns:
        events_df["proto_num"] = events_df["proto"].map(PROTO_MAP).fillna(0)
    else:
        events_df["proto_num"] = 0

    # DNS type -> number (NaN for non-DNS events)
    if "dns_type" in events_df.columns:
        events_df["dns_type_num"] = events_df["dns_type"].map(DNS_TYPE_MAP)
    else:
        events_df["dns_type_num"] = float("nan")

    # Flow connection state -> number (NaN for non-flow events; 99 for unknown)
    if "flow_state" in events_df.columns:
        events_df["flow_state_num"] = events_df["flow_state"].map(FLOW_STATE_MAP).fillna(99)
    else:
        events_df["flow_state_num"] = float("nan")

    # Flow end reason -> number (NaN for non-flow events; 99 for unknown)
    if "flow_reason" in events_df.columns:
        events_df["flow_reason_num"] = events_df["flow_reason"].map(FLOW_REASON_MAP).fillna(99)
    else:
        events_df["flow_reason_num"] = float("nan")

    # DNS response code -> number (NaN for non-DNS events; 0 = NOERROR default)
    if "dns_rcode" in events_df.columns:
        events_df["dns_rcode_num"] = events_df["dns_rcode"].map(DNS_RCODE_MAP).fillna(0)
    else:
        events_df["dns_rcode_num"] = float("nan")

    # TCP flags: bool -> int  (True=1, False/NaN=0)
    # All four flags need the same treatment - tcp_rst was the only one converted
    # before; tcp_syn, tcp_fin, tcp_ack were left as raw Python booleans which
    # caused inconsistencies when events had no TCP section (NaN instead of 0).
    for flag in ("tcp_syn", "tcp_fin", "tcp_ack", "tcp_rst"):
        if flag in events_df.columns:
            events_df[flag] = events_df[flag].fillna(False).astype(int)
        else:
            events_df[flag] = 0

    return events_df


def add_derived_features(events_df):
    """
    Creates new columns derived from existing traffic metrics.
    Copied from notebook - Step 4a.

    For non-flow events (dns, http...) the flow_* columns are NaN and
    will become 0 after fillna(0).
    """
    for col in ["flow_pkts_toserver", "flow_pkts_toclient",
                "flow_bytes_toserver", "flow_bytes_toclient"]:
        if col not in events_df.columns:
            events_df[col] = float("nan")

    total_packets = (events_df["flow_pkts_toserver"].fillna(0)
                     + events_df["flow_pkts_toclient"].fillna(0))
    total_bytes   = (events_df["flow_bytes_toserver"].fillna(0)
                     + events_df["flow_bytes_toclient"].fillna(0))

    events_df["bytes_per_pkt"] = total_bytes / total_packets.clip(lower=1)
    events_df["pkt_ratio"]     = (events_df["flow_pkts_toserver"].fillna(0)
                                  / events_df["flow_pkts_toclient"].fillna(0).clip(lower=1))
    events_df["bytes_ratio"]   = (events_df["flow_bytes_toserver"].fillna(0)
                                  / events_df["flow_bytes_toclient"].fillna(0).clip(lower=1))

    return events_df


def add_time_window_features(events_df, window_size="30s"):
    """
    Adds features that count similar events within a rolling time window.
    Copied from notebook - Step 4b.

    These features are the main reason time windows beat fixed-size batches:
    a 30 s window makes it possible to distinguish "50 normal connections over
    30 s" from "50,000 DoS packets over 30 s".

    Features added:
      - flows_to_dest_port_wndw         DoS
      - unique_srcs_to_dest_wndw        DDoS
      - flows_from_src_wndw             brute force
      - unique_dest_ports_from_src_wndw port scan
    """
    events_df["_ts"]     = pd.to_datetime(events_df["timestamp"], utc=True, errors="coerce")
    events_df["_window"] = events_df["_ts"].dt.floor(window_size)

    count_to_dest = (
        events_df.groupby(["_window", "dest_ip", "dest_port"])
        .size()
        .reset_index(name="flows_to_dest_port_wndw")
    )
    events_df = events_df.merge(count_to_dest, on=["_window", "dest_ip", "dest_port"], how="left")

    unique_sources = (
        events_df.groupby(["_window", "dest_ip", "dest_port"])["src_ip"]
        .nunique()
        .reset_index(name="unique_srcs_to_dest_wndw")
    )
    events_df = events_df.merge(unique_sources, on=["_window", "dest_ip", "dest_port"], how="left")

    count_from_src = (
        events_df.groupby(["_window", "src_ip"])
        .size()
        .reset_index(name="flows_from_src_wndw")
    )
    events_df = events_df.merge(count_from_src, on=["_window", "src_ip"], how="left")

    unique_dest_ports = (
        events_df.groupby(["_window", "src_ip"])["dest_port"]
        .nunique()
        .reset_index(name="unique_dest_ports_from_src_wndw")
    )
    events_df = events_df.merge(unique_dest_ports, on=["_window", "src_ip"], how="left")

    events_df = events_df.drop(columns=["_ts", "_window"])
    return events_df


def build_feature_dataframe(raw_event_rows):
    """
    Takes a list of raw flattened JSON event dicts and runs the full notebook
    pipeline to produce the feature DataFrame the model expects.

    Returns:
        feature_df : DataFrame (n_events x len(FEATURES)) - ready for scaler/model
        events_df  : DataFrame with ALL columns - used to build alert details
    """
    events_df = pd.DataFrame(raw_event_rows)

    for required_col in ["timestamp", "src_ip", "dest_ip", "dest_port"]:
        if required_col not in events_df.columns:
            events_df[required_col] = None

    events_df = encode_text_fields(events_df)
    events_df = add_derived_features(events_df)
    events_df = add_time_window_features(events_df)

    for col in FEATURES:
        if col not in events_df.columns:
            events_df[col] = float("nan")

    # Keep as DataFrame (not .values) so the scaler recognises the column names
    # it was fitted with and does not print "X does not have valid feature names"
    feature_df = events_df[FEATURES].fillna(0)
    return feature_df, events_df


# ──────────────────────────────────────────────────────────────────────────────
# DOCKER LOG READER  (background thread)
# ──────────────────────────────────────────────────────────────────────────────

def docker_log_reader(container_name, eve_log_path, new_line_queue, stop_event):
    """
    Streams eve.json from the Docker container in real time via docker exec tail -F.
    Puts ("LINE", raw_json_string) or ("ERROR", message) on the queue.
    """
    command = ["docker", "exec", container_name, "tail", "-F", eve_log_path]

    try:
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1,
        )
    except FileNotFoundError:
        new_line_queue.put(("ERROR", "docker command not found - is Docker installed?"))
        return

    while not stop_event.is_set():
        raw_line = process.stdout.readline()
        if not raw_line:
            if process.poll() is not None:
                new_line_queue.put(("ERROR", f"Container '{container_name}' stopped unexpectedly."))
                break
            time.sleep(0.05)
            continue
        raw_line = raw_line.strip()
        if raw_line:
            new_line_queue.put(("LINE", raw_line))

    try:
        process.kill()
    except Exception:
        pass


# ──────────────────────────────────────────────────────────────────────────────
# CURSES HELPER
# ──────────────────────────────────────────────────────────────────────────────

def draw_panel(screen, top_row, left_col, height, width,
               title, content_lines, text_color, show_latest_at_bottom=False):
    """
    Draws a rectangular bordered panel with a centred title and content lines.
    Every curses call is individually wrapped so a single failed character
    write never kills the entire panel.
    """
    if height < 3 or width < 4:
        return

    border_style = curses.color_pair(1) | curses.A_BOLD
    bottom_row   = top_row + height - 1

    # ── Corners ───────────────────────────────────────────────────────────────
    for row, col in [
        (top_row,    left_col),
        (top_row,    left_col + width - 1),
        (bottom_row, left_col),
        (bottom_row, left_col + width - 1),
    ]:
        try:
            screen.addch(row, col, "+", border_style)
        except curses.error:
            pass

    # ── Horizontal borders ────────────────────────────────────────────────────
    for col_offset in range(1, width - 1):
        try:
            screen.addch(top_row,    left_col + col_offset, "-", border_style)
        except curses.error:
            pass
        try:
            screen.addch(bottom_row, left_col + col_offset, "-", border_style)
        except curses.error:
            pass

    # ── Vertical borders ──────────────────────────────────────────────────────
    for row_offset in range(1, height - 1):
        try:
            screen.addch(top_row + row_offset, left_col,             "|", border_style)
        except curses.error:
            pass
        try:
            screen.addch(top_row + row_offset, left_col + width - 1, "|", border_style)
        except curses.error:
            pass

    # ── Title ─────────────────────────────────────────────────────────────────
    if len(title) < width - 4:
        title_col = left_col + max(2, (width - len(title)) // 2)
        try:
            screen.addstr(top_row, title_col, title, curses.color_pair(1) | curses.A_BOLD)
        except curses.error:
            pass

    # ── Content ───────────────────────────────────────────────────────────────
    available_rows = height - 2
    available_cols = width  - 4

    if available_rows <= 0 or available_cols <= 0:
        return

    lines_to_show = (content_lines[-available_rows:] if show_latest_at_bottom
                     else content_lines[:available_rows])

    for i, line in enumerate(lines_to_show):
        draw_row = top_row + 1 + i
        if draw_row >= bottom_row:
            break
        try:
            screen.addstr(draw_row, left_col + 2, line[:available_cols],
                          curses.color_pair(text_color))
        except curses.error:
            pass


# ──────────────────────────────────────────────────────────────────────────────
# THRESHOLD LOADING
# ──────────────────────────────────────────────────────────────────────────────

def load_threshold(models_dir, cli_threshold):
    """
    Priority: CLI arg > model_threshold.txt > model.offset_ (pkl fallback).
    Returns (threshold_value, source_description_string).
    """
    if cli_threshold is not None:
        return cli_threshold, f"command-line argument ({cli_threshold:.4f})"

    threshold_file = Path(models_dir) / "model_threshold.txt"
    if threshold_file.exists():
        try:
            with open(threshold_file) as f:
                value = float(f.read().strip())
            return value, f"model_threshold.txt ({value:.4f})"
        except (ValueError, OSError):
            pass

    return None, "model.offset_ (pkl fallback)"


# ──────────────────────────────────────────────────────────────────────────────
# PANEL LAYOUT
# ──────────────────────────────────────────────────────────────────────────────

def calculate_panel_layout(terminal_rows):
    """
    Calculates the height and starting row of each of the 4 panels.

    Layout:
      - top ~1/3    : live events
      - middle ~1/3 : anomaly alerts
      - bottom ~1/6 : statistics
      - bottom ~1/6 : model info

    Panels are clamped to the actual terminal height so they never overflow.
    """
    MIN_STATS_HEIGHT = 6
    MIN_MODEL_HEIGHT = 10
    MIN_PANEL_HEIGHT = 4    # minimum for events and alerts panels

    # Bottom panels claim their space first
    stats_height = max(MIN_STATS_HEIGHT, terminal_rows // 6)
    model_height = max(MIN_MODEL_HEIGHT, terminal_rows // 6)

    # Clamp so bottom panels never exceed the terminal on their own
    bottom_total = stats_height + model_height
    if bottom_total >= terminal_rows:
        # Scale both down proportionally
        stats_height = max(MIN_STATS_HEIGHT, terminal_rows // 4)
        model_height = max(MIN_MODEL_HEIGHT, terminal_rows // 4)
        bottom_total = stats_height + model_height

    remaining_rows = max(terminal_rows - bottom_total, MIN_PANEL_HEIGHT * 2)
    events_height  = max(MIN_PANEL_HEIGHT, remaining_rows // 2)
    alerts_height  = max(MIN_PANEL_HEIGHT, remaining_rows - events_height)

    # Recalculate actual totals now that we have firm heights
    # If everything overshoots, shrink proportionally from the bottom
    total = events_height + alerts_height + stats_height + model_height
    if total > terminal_rows:
        diff = total - terminal_rows
        model_height  = max(MIN_MODEL_HEIGHT,  model_height  - diff)
        stats_height  = max(MIN_STATS_HEIGHT,  stats_height  - max(0, diff - model_height))

    events_top = 0
    alerts_top = events_height
    stats_top  = events_height + alerts_height
    model_top  = stats_top + stats_height

    return {
        "events": {"height": events_height, "top_row": events_top},
        "alerts": {"height": alerts_height, "top_row": alerts_top},
        "stats":  {"height": stats_height,  "top_row": stats_top},
        "model":  {"height": model_height,  "top_row": model_top},
    }


# ──────────────────────────────────────────────────────────────────────────────
# MAIN CURSES UI
# ──────────────────────────────────────────────────────────────────────────────

def run_detector(screen, container_name, models_dir, cli_threshold,
                 window_seconds, eve_log_path):
    """
    Main loop: sets up curses, loads the model, starts the reader thread,
    and runs the time-windowed detection + display loop until 'q' is pressed.
    """

    # Redirect stderr so stray warnings never corrupt the curses display
    devnull_fd  = open(os.devnull, "w")
    sys.stderr  = devnull_fd

    # ── Curses setup ──────────────────────────────────────────────────────────
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()

    curses.init_pair(1, curses.COLOR_CYAN,    -1)   # borders and titles
    curses.init_pair(2, curses.COLOR_RED,     -1)   # anomaly alerts
    curses.init_pair(3, curses.COLOR_GREEN,   -1)   # live events
    curses.init_pair(4, curses.COLOR_YELLOW,  -1)   # statistics
    curses.init_pair(5, curses.COLOR_MAGENTA, -1)   # model information

    screen.nodelay(True)

    # ── Load model files ──────────────────────────────────────────────────────
    scaler_path = Path(models_dir) / "scaler.pkl"
    model_path  = Path(models_dir) / "isolation_forest.pkl"

    if not scaler_path.exists() or not model_path.exists():
        try:
            screen.addstr(0, 0, f"ERROR: Model files not found in {models_dir}")
            screen.addstr(1, 0, "Run the notebook first: ml/notebooks/VNTD_ML.ipynb")
            screen.refresh()
        except curses.error:
            pass
        time.sleep(5)
        return

    scaler = joblib.load(scaler_path)
    model  = joblib.load(model_path)

    threshold, threshold_source = load_threshold(models_dir, cli_threshold)
    if threshold is None:
        threshold        = model.offset_
        threshold_source = f"model.offset_ ({model.offset_:.4f})"

    # ── Runtime state ─────────────────────────────────────────────────────────
    start_time      = time.time()
    last_flush_time = time.time()   # when the current window started
    total_events    = 0
    total_anomalies = 0
    total_windows   = 0             # how many windows have been scored so far

    events_buffer   = []            # events buffered for the current window
    event_log_lines = []            # shown in the live events panel  (max 500)
    alert_lines     = []            # shown in the alerts panel        (max 200)
    last_error      = None          # last pipeline error (shown in stats)

    # ── Start background reader thread ────────────────────────────────────────
    new_line_queue = queue.Queue()
    stop_event     = threading.Event()

    reader_thread = threading.Thread(
        target=docker_log_reader,
        args=(container_name, eve_log_path, new_line_queue, stop_event),
        daemon=True,
    )
    reader_thread.start()

    # ── Main loop ─────────────────────────────────────────────────────────────
    while True:

        # Check for quit
        try:
            pressed_key = screen.getch()
        except curses.error:
            pressed_key = -1
        if pressed_key in (ord("q"), ord("Q")):
            break

        terminal_rows, terminal_cols = screen.getmaxyx()
        layout = calculate_panel_layout(terminal_rows)

        # ── Drain the queue ────────────────────────────────────────────────
        lines_read = 0
        try:
            while lines_read < 200:
                message_type, message_data = new_line_queue.get_nowait()
                lines_read += 1

                if message_type == "ERROR":
                    event_log_lines.append(f"[ERROR] {message_data}")
                    stop_event.set()

                elif message_type == "LINE":
                    try:
                        raw_event = json.loads(message_data)
                    except json.JSONDecodeError:
                        continue

                    if raw_event.get("event_type") in EXCLUDE_TYPES:
                        continue

                    flat_event = flatten_json(raw_event)
                    events_buffer.append(flat_event)

                    # Build summary line for the live events panel
                    timestamp   = str(raw_event.get("timestamp", ""))
                    time_str    = timestamp[11:19] if len(timestamp) >= 19 else "--:--:--"
                    event_type  = str(raw_event.get("event_type", "?")).upper()
                    protocol    = str(raw_event.get("proto", "?"))
                    source      = f"{raw_event.get('src_ip','?')}:{raw_event.get('src_port','?')}"
                    destination = f"{raw_event.get('dest_ip','?')}:{raw_event.get('dest_port','?')}"

                    event_log_lines.append(
                        f"[{time_str}] {event_type:<8} {protocol:<5} {source} -> {destination}"
                    )
                    if len(event_log_lines) > 500:
                        event_log_lines.pop(0)

        except queue.Empty:
            pass

        # ── Score when the time window closes ──────────────────────────────
        # Fire if (a) window_seconds have elapsed AND there is at least 1 event,
        # OR (b) we have accumulated a very large buffer (safety valve).
        current_time        = time.time()
        window_elapsed      = current_time - last_flush_time
        buffer_safety_valve = len(events_buffer) >= 5000

        if (window_elapsed >= window_seconds and len(events_buffer) > 0) or buffer_safety_valve:

            window_event_count = len(events_buffer)

            try:
                feature_df, events_df = build_feature_dataframe(events_buffer)
                scaled = scaler.transform(feature_df)
                anomaly_scores = model.score_samples(scaled)
                is_anomaly     = anomaly_scores < threshold

                total_events    += window_event_count
                total_anomalies += int(is_anomaly.sum())
                total_windows   += 1
                last_error       = None

                # Build alert lines for each flagged event
                for idx in np.where(is_anomaly)[0]:
                    flagged   = events_df.iloc[idx]
                    score_val = float(anomaly_scores[idx])

                    timestamp   = str(flagged.get("timestamp", ""))
                    time_str    = timestamp[11:19] if len(timestamp) >= 19 else "--:--:--"
                    event_type  = str(flagged.get("event_type", "?")).upper()
                    protocol    = str(flagged.get("proto", "?"))
                    source      = f"{flagged.get('src_ip','?')}:{int(flagged.get('src_port', 0) or 0)}"
                    destination = f"{flagged.get('dest_ip','?')}:{int(flagged.get('dest_port', 0) or 0)}"

                    alert_lines.append(
                        f"[{time_str}] ANOMALY score={score_val:.3f}  "
                        f"{event_type} {protocol}  {source} -> {destination}"
                    )

                    flows_to_dest   = int(flagged.get("flows_to_dest_port_wndw",        0) or 0)
                    flows_from_src  = int(flagged.get("flows_from_src_wndw",             0) or 0)
                    unique_ports    = int(flagged.get("unique_dest_ports_from_src_wndw", 0) or 0)
                    unique_sources  = int(flagged.get("unique_srcs_to_dest_wndw",        0) or 0)
                    tcp_rst_flag    = int(flagged.get("tcp_rst",                         0) or 0)
                    dns_rcode_value = int(flagged.get("dns_rcode_num",                   0) or 0)

                    if flows_to_dest  > 100:
                        alert_lines.append(f"  -> Possible DoS: {flows_to_dest:,} connections to same destination")
                    if flows_from_src > 100:
                        alert_lines.append(f"  -> Possible Brute-force: {flows_from_src:,} connections from same source")
                    if unique_ports   > 20:
                        alert_lines.append(f"  -> Possible Port scan: {unique_ports} unique destination ports")
                    if unique_sources > 10:
                        alert_lines.append(f"  -> Possible DDoS: {unique_sources} unique source IPs")
                    if tcp_rst_flag:
                        alert_lines.append("  -> TCP RST flag set (connection forcibly rejected)")
                    if dns_rcode_value == 2:
                        alert_lines.append("  -> DNS REFUSED response (possible DNS abuse)")
                    elif dns_rcode_value == 1:
                        alert_lines.append("  -> DNS NXDOMAIN response (domain does not exist)")

                if len(alert_lines) > 200:
                    alert_lines = alert_lines[-200:]

            except Exception as err:
                last_error = str(err)
                event_log_lines.append(f"[PIPELINE ERROR] {err}")

            events_buffer.clear()
            last_flush_time = current_time

        # ── Draw panels ────────────────────────────────────────────────────
        try:
            screen.erase()
        except curses.error:
            pass

        # Panel 1 - live events
        draw_panel(
            screen,
            top_row=layout["events"]["top_row"],
            left_col=0,
            height=layout["events"]["height"],
            width=terminal_cols,
            title="[ Live events ]",
            content_lines=event_log_lines,
            text_color=3,
            show_latest_at_bottom=True,
        )

        # Panel 2 - anomaly alerts
        draw_panel(
            screen,
            top_row=layout["alerts"]["top_row"],
            left_col=0,
            height=layout["alerts"]["height"],
            width=terminal_cols,
            title="[ Anomaly alerts ]",
            content_lines=alert_lines,
            text_color=2,
            show_latest_at_bottom=True,
        )

        # Panel 3 - runtime statistics
        elapsed_seconds   = int(time.time() - start_time)
        hours, remainder  = divmod(elapsed_seconds, 3600)
        minutes, seconds  = divmod(remainder, 60)
        events_per_second = total_events / elapsed_seconds if elapsed_seconds > 0 else 0.0
        time_until_flush  = max(0, window_seconds - (time.time() - last_flush_time))

        stats_lines = [
            f"  Runtime          : {hours:02d}:{minutes:02d}:{seconds:02d}",
            f"  Events processed : {total_events:,}   ({events_per_second:.1f} ev/s)",
            f"  Anomalies found  : {total_anomalies:,}",
            f"  Windows scored   : {total_windows}   (next in {time_until_flush:.0f}s,"
            f" {len(events_buffer)} events buffered)",
            f"  Press 'q' to quit",
        ]
        if last_error:
            stats_lines.append(f"  Last error: {last_error[:80]}")

        draw_panel(
            screen,
            top_row=layout["stats"]["top_row"],
            left_col=0,
            height=layout["stats"]["height"],
            width=terminal_cols,
            title="[ Statistics ]",
            content_lines=stats_lines,
            text_color=4,
        )

        # Panel 4 - model information
        model_info_lines = [
            f"  Model            : Isolation Forest (scikit-learn)",
            f"  Trees (n_est.)   : {model.n_estimators}",
            f"  Max features     : {model.max_features}",
            f"  Contamination    : {model.contamination}",
            f"  Features used    : {len(FEATURES)}",
            f"  Threshold        : {threshold:.4f}   (source: {threshold_source})",
            f"  Window size      : {window_seconds}s",
            f"  Container        : {container_name}",
            f"  Log file         : {eve_log_path}",
        ]
        draw_panel(
            screen,
            top_row=layout["model"]["top_row"],
            left_col=0,
            height=layout["model"]["height"],
            width=terminal_cols,
            title="[ AI Model ]",
            content_lines=model_info_lines,
            text_color=5,
        )

        try:
            screen.refresh()
        except curses.error:
            pass

        time.sleep(0.1)

    # ── Cleanup ───────────────────────────────────────────────────────────────
    stop_event.set()
    devnull_fd.close()


# ──────────────────────────────────────────────────────────────────────────────
# ENTRY POINT
# ──────────────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Real-time anomaly detection using Isolation Forest - VNTD"
    )
    parser.add_argument(
        "--container",
        required=True,
        help="Name of the logwatch Docker container",
    )
    parser.add_argument(
        "--models",
        required=True,
        help="Directory containing scaler.pkl and isolation_forest.pkl",
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=None,
        help=(
            "Anomaly score threshold (optional). "
            "If not set, model_threshold.txt is tried first, then model.offset_."
        ),
    )
    parser.add_argument(
        "--window",
        type=int,
        default=30,
        help=(
            "Time window in seconds before scoring the buffered events (default: 30). "
            "Larger windows give the time-window features more events to count over, "
            "making DoS/DDoS/scan detection more reliable."
        ),
    )
    parser.add_argument(
        "--eve-log",
        default="/var/log/suricata/eve.json",
        help="Path to eve.json inside the container",
    )
    args = parser.parse_args()

    curses.wrapper(
        run_detector,
        args.container,
        args.models,
        args.threshold,
        args.window,
        args.eve_log,
    )


if __name__ == "__main__":
    main()
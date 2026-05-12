"""
pipeline.py
===========
This file handles everything related to data processing and the ML model.
It is the equivalent of what the notebook does.

It's not necessary to modify this file, unless the model is retrained with different features in 
the notebook. If retrained, make sure to update the FEATURES list and the encodings below.

Steps from the notebook that live here:
    Step 0  ->  EXCLUDE_TYPES and encoding maps (constants first)
    Step 1  ->  flatten_json()
    Step 3  ->  encode_fields()
    Step 4a ->  add_features()
    Step 4b ->  add_time_window_features()
    Step 6  ->  FEATURES list + build_feature_dataframe()
    Step 7  ->  scaler.transform() is called inside score_batch()
    Step 8  ->  model.score_samples() is called inside score_batch()
"""

import math
import warnings
from pathlib import Path

# Silence sklearn warnings before importing it.
# If don't, messages like "feature names mismatch" would get printed
warnings.filterwarnings("ignore")

import joblib
import numpy as np
import pandas as pd

# =============================================================================
# STEP 0 - Settings / constants
# These must match exactly what was used in the notebook when training.
# Changing these without retraining will break the model.
# =============================================================================

EXCLUDE_TYPES = {"alert"}

# What kind of event is it?
EVENT_TYPE_MAP = {
    "flow":     0,
    "dns":      1,
    "http":     2,
    "smtp":     3,
    "anomaly":  4,
    "ssh":      5,
    "tls":      6,
    "fileinfo": 7,
    "netflow":  8,
}

# What network protocol was used?
PROTO_MAP = {
    "ICMP":      1,
    "TCP":       6,
    "UDP":       17,
    "IPv6-ICMP": 58,
}

# For DNS events: was this a query (asking) or an answer (replying)?
DNS_TYPE_MAP = {
    "query":  0,
    "answer": 1,
}

# For flow events: what state was the connection in when it ended?
FLOW_STATE_MAP = {
    "closed":      0,
    "established": 1,
    "new":         2,
    "syn_sent":    3,
}

# For flow events: why did the connection end?
FLOW_REASON_MAP = {
    "fin":     0,
    "rst":     1,
    "timeout": 2,
    "forced":  3,
}

# For DNS events: what was the server's response code?
DNS_RCODE_MAP = {
    "NOERROR":  0,
    "NXDOMAIN": 1,
    "REFUSED":  2,
    "SERVFAIL": 3,
}

# =============================================================================
# STEP 6 - Feature list
# Exact list of columns the model was trained on.
# The ORDER matters. The NAMES matter. Missing or extra columns will crash.
# =============================================================================

FEATURES = [
    # --- all events ---
    "event_type_num",       # type of event: flow=0, dns=1, http=2...
    "proto_num",            # network protocol: TCP=6, UDP=17, ICMP=1...
    "src_port",             # where the connection came from (port number)
    "dest_port",            # where it was going (port number)
    # --- flow events ---
    "flow_state_num",       # connection state when it ended
    "flow_reason_num",      # why the connection ended
    "flow_pkts_toserver",   # how many packets were sent to the server
    "flow_pkts_toclient",   # how many packets came back from the server
    "flow_bytes_toserver",  # how many bytes were sent to the server
    "flow_bytes_toclient",  # how many bytes came back
    "flow_age",             # how long the connection lasted
    # --- derived from flow ---
    "bytes_per_pkt",        # average size of each packet - tiny = possible scan
    "pkt_ratio",            # are we sending way more packets than we receive? (DoS sign)
    "bytes_ratio",          # are we sending way more bytes than we receive?
    # --- TCP flags (flow events only, 0 for UDP/ICMP) ---
    "tcp_syn",              # someone started a connection
    "tcp_fin",              # connection closed normally
    "tcp_ack",              # acknowledging data
    "tcp_rst",              # connection was forcibly cut off
    # --- HTTP events ---
    "http_status",          # response code: 200 OK, 404 not found, 500 error...
    "http_length",          # how big was the HTTP response body
    # --- DNS events ---
    "dns_type_num",         # was it a query or an answer?
    "dns_rcode_num",        # what was the response code?
    # --- time window features ---
    "flows_to_dest_port_wndw",          # how many connections to the same IP/port? (DoS)
    "unique_srcs_to_dest_wndw",         # how many different IPs attacked the same target? (DDoS)
    "flows_from_src_wndw",              # how many connections from the same source? (brute force)
    "unique_dest_ports_from_src_wndw",  # how many different ports did one IP try? (port scan)
]

# =============================================================================
# CONVERSION TOOLS
# Suricata events sometimes have missing or weird values (None, NaN, etc).
# These help convert those to appropiate values.
# =============================================================================

def convert_int(value, default=0):
    """
    Convert a value to an integer. Returns `default` if it can't.

    Why do we need this?
    Python's normal int will crash if you give it float('nan'). It needs to check for NaN explicitly.

    Examples:
        convert_int(443)            -> 443
        convert_int(None)           -> 0
        convert_int(float('nan'))   -> 0
        convert_int("not a number") -> 0
    """
    if value is None:
        return default
    try:
        float_val = float(value)
        if math.isnan(float_val):
            return default
        return int(float_val)
    except (TypeError, ValueError):
        return default

def convert_str(value, default="?"):
    """
    Converts a value to string. Returns `default` if the value is None or NaN.
    """
    if value is None:
        return default
    try:
        if math.isnan(float(value)):
            return default
    except (TypeError, ValueError):
        pass  # it's not a float, so it's not NaN - just convert it normally
    return str(value)

def append_lines(line_list, text, max_lines=500):
    """
    Adds text to a list, splitting it into separate lines first.
    Trims the list to max_lines.
    Split the text as if the content is an error message, the content may not fit in a single line 
    and cause text overlapping on displaying.
    """
    for line in str(text).splitlines():
        line_list.append(line)
    if len(line_list) > max_lines:
        del line_list[:-max_lines]

# =============================================================================
# STEP 1 - flatten_json
# Suricata events are nested JSON objects. The model needs flat columns.
# This function recursively unpacks nested dicts and lists into flat keys.
# =============================================================================

def flatten_json(d, parent_key="", sep="_"):
    """
    Recursively flattens a nested dictionary

    For example:
        {"flow": {"age": 5, "state": "closed"}}
        becomes:
        {"flow_age": 5, "flow_state": "closed"}

    And for lists:
        {"answers": [{"data": "1.2.3.4"}]}
        becomes:
        {"answers_0_data": "1.2.3.4"}
    """
    items = []

    for k, v in d.items():
        # Build the new key appending the parent path
        new_key = f"{parent_key}{sep}{k}" if parent_key else k

        if isinstance(v, dict):
            #  Recursive into nested dictionaries
            items.extend(flatten_json(v, new_key, sep=sep).items())

        elif isinstance(v, list):
            if len(v) == 0:
                # Empty list -> store as None so the column still exists
                items.append((new_key, None))
            else:
                for i, item in enumerate(v):
                    list_key = f"{new_key}{sep}{i}"

                    if isinstance(item, dict):
                        items.extend(flatten_json(item, list_key, sep=sep).items())
                    else:
                        items.append((list_key, item))
        else:
            items.append((new_key, v))

    return dict(items)

# =============================================================================
# STEP 3 - encode_fields
# Converts all the text columns into numbers using the maps defined above.
# Fields that don't exist for a given event type are set to NaN (filled to 0 later).
# =============================================================================

def encode_fields(df):
    """
    Converts text columns into numbers so the model can read them.
    """

        # Event type: unknown event types get 99
    df["event_type_num"] = df["event_type"].map(EVENT_TYPE_MAP).fillna(99)

    # Protocol: unknown protocols get 0
    df["proto_num"] = df["proto"].map(PROTO_MAP).fillna(0)

    # DNS type: only on DNS events; NaN for everything else
    if "dns_type" in df.columns:
        df["dns_type_num"] = df["dns_type"].map(DNS_TYPE_MAP)
    else:
        df["dns_type_num"] = float("nan")

    # Flow state: only on flow events; 99 for any unknown state
    if "flow_state" in df.columns:
        df["flow_state_num"] = df["flow_state"].map(FLOW_STATE_MAP).fillna(99)
    else:
        df["flow_state_num"] = float("nan")

    # Flow reason: why was closed; 99 for unknown reasons
    if "flow_reason" in df.columns:
        df["flow_reason_num"] = df["flow_reason"].map(FLOW_REASON_MAP).fillna(99)
    else:
        df["flow_reason_num"] = float("nan")

    # DNS response code: only on DNS events; 0 (NOERROR) for non-DNS
    if "dns_rcode" in df.columns:
        df["dns_rcode_num"] = df["dns_rcode"].map(DNS_RCODE_MAP).fillna(0)
    else:
        df["dns_rcode_num"] = float("nan")

    # TCP SYN flag: True when a connection was initiated
    if "tcp_syn" in df.columns:
        df["tcp_syn"] = df["tcp_syn"].fillna(False).astype(int)
    else:
        df["tcp_syn"] = 0

    # TCP FIN flag: True when a connection was cleanly closed
    if "tcp_fin" in df.columns:
        df["tcp_fin"] = df["tcp_fin"].fillna(False).astype(int)
    else:
        df["tcp_fin"] = 0

    # TCP ACK flag: True when acknowledging received data
    if "tcp_ack" in df.columns:
        df["tcp_ack"] = df["tcp_ack"].fillna(False).astype(int)
    else:
        df["tcp_ack"] = 0

    # TCP RST flag: True when a connection was forced rejected
    if "tcp_rst" in df.columns:
        df["tcp_rst"] = df["tcp_rst"].fillna(False).astype(int)
    else:
        df["tcp_rst"] = 0
    
    return df

# =============================================================================
# STEP 4a - add_features
# Creates three new columns that measure traffic.
# These help the model spot DoS floods and port scans more easily.
# =============================================================================

def add_features(df):
    """
    Adds three ratio columns computed from the flow byte/packet counts.

    What each one signals:
      bytes_per_pkt  low  -> lots of tiny packets = possible scan
      pkt_ratio      high -> many packets sent, few received = possible DoS
      bytes_ratio    high -> many bytes sent, few received = one-sided traffic

    For non-flow events (DNS, HTTP...) the flow columns don't exist and default to NaN, which
    becomes 0 after fillna(0) later.

    .clip(lower=1) prevents division by zero when the denominator would be 0.
    """
    # Ensure the columns exist, even if no flow events are present
    for col in ["flow_pkts_toserver", "flow_pkts_toclient", "flow_bytes_toserver", "flow_bytes_toclient"]:
        if col not in df.columns:
            df[col] = float("nan")

    total_pkts = df["flow_pkts_toserver"].fillna(0) + df["flow_pkts_toclient"].fillna(0)
    total_bytes = df["flow_bytes_toserver"].fillna(0) + df["flow_bytes_toclient"].fillna(0)

    df["bytes_per_pkt"] = total_bytes / total_pkts.clip(lower=1)

    df["pkt_ratio"] = df["flow_pkts_toserver"].fillna(0) / df["flow_pkts_toclient"].fillna(0).clip(lower=1)

    df["bytes_ratio"] = df["flow_bytes_toserver"].fillna(0) / df["flow_bytes_toclient"].fillna(0).clip(lower=1)

    return df

# =============================================================================
# STEP 4b - add_time_window_features
# Counts how many similar events happened in the same 30-second window.
# This is how the model detects attacks that look normal one packet at a time but are obviously
# suspicious when you look at the volume.
# =============================================================================

def add_time_window_features(df, window_size="30s"):
    """
    Add features that count similar events within a time window (default 30 seconds)
    The idea: a single TCP SYN to port 80 is normal, 50.000 TCP SYNs to port 80 in 30 seconds is a DoS attack.

    Features added:
      flows_to_dest_port_wndw         -> many connections to same IP:port (DoS)
      unique_srcs_to_dest_wndw        -> many IPs hitting same target (DDoS)
      flows_from_src_wndw             -> same IP making many connections (brute force)
      unique_dest_ports_from_src_wndw -> same IP trying many ports (port scan)
    """
    
    # Convert the timestamp string into a datetime object
    df["_ts"] = pd.to_datetime(df["timestamp"])

    # Group events into time window by rounding the timestamp to the nearest window
    df["_window"] = df["_ts"].dt.floor(window_size)

    # How many flows went to the same (dest_ip, dest_port)
    counts_to_dest = (
        df.groupby(["_window", "dest_ip", "dest_port"])
        .size()
        .reset_index(name="flows_to_dest_port_wndw")
    )
    df = df.merge(counts_to_dest, on=["_window", "dest_ip", "dest_port"], how="left")

    # How many unique source IPs get to the same (dest_ip, dest_port)
    unique_srcs = (
        df.groupby(["_window", "dest_ip", "dest_port"])["src_ip"]
        .nunique()
        .reset_index(name="unique_srcs_to_dest_wndw")
    )
    df = df.merge(unique_srcs, on=["_window", "dest_ip", "dest_port"], how="left")

    # How many flows came from the same source IP
    counts_from_src = (
        df.groupby(["_window", "src_ip"])
        .size()
        .reset_index(name="flows_from_src_wndw")
    )
    df = df.merge(counts_from_src, on=["_window", "src_ip"], how="left")

    # How many unique destination ports
    unique_ports = (
        df.groupby(["_window", "src_ip"])["dest_port"]
        .nunique()
        .reset_index(name="unique_dest_ports_from_src_wndw")
    )
    df = df.merge(unique_ports, on=["_window", "src_ip"], how="left")

    # Remove the temporary columns created for grouping
    df = df.drop(columns=["_ts", "_window"])

    return df

# =============================================================================
# STEP 6 + 7 - build_feature_dataframe
# Runs all the steps above on a batch of raw events and returns the
# feature table that the scaler and model expect.
# =============================================================================

def build_feature_dataframe(raw_event_rows):
    """
    Takes a list of flattened event dicts and returns two DataFrames:

    - feature_df - the 26 columns the model needs, with NaN and similar replaced by 0. This is what
                   gets passed to scaler.transform() and model.score_samples().

    - events_df - the full table with every column, used to build the alert display lines.

    The pipeline order matches the notebook exactly:
      encode text (Step 3) -> derive ratios (Step 4a) -> time windows (Step 4b) -> select columns (Step 6)

    Important: feature_df returns as a DataFrame, not a numpy array. If convertedwitho .values, the
    scaler would lose the column names.
    """

    events_df = pd.DataFrame(raw_event_rows)

    # Make sure these core columns exist (all events should include them)
    for col in ["timestamp", "src_ip", "dest_ip", "dest_port"]:
        if col not in events_df.columns:
            events_df[col] = None

    # Run the pipeline steps in order
    events_df = encode_fields(events_df)            # Step 3
    events_df = add_features(events_df)             # Step 4a
    events_df = add_time_window_features(events_df) # Step 4b

    # Add any feature column that doesn't exist yet (e.g. http_status when there are no HTTP events)
    for col in FEATURES:
        if col not in events_df.columns:
            events_df[col] = float("nan")

    # Select only the 26 feature columns, replace NaN with 0
    feature_df = events_df[FEATURES].fillna(0)

    return feature_df, events_df

# =============================================================================
# LOADING THRESHOLD
# Threshold decides "when an event is too anomalous". A score below threshold -> flagged as attack.
# =============================================================================

def load_threshold(models_dir, cli_threshold):
    """
    Finds the right threshold to use, checking in this order:

    1. --threshold
    2. model_threshold.txt
    3. model.offset_ found in the .pkl file

    Returns (threshold value or None, description string)
    The caller should check for None and load model.offset_ if needed.
    """
    if cli_threshold is not None:
        return cli_threshold, f"command-line argument ({cli_threshold:.4f})"

    threshold_file = Path(models_dir) / "model_threshold.txt"
    if threshold_file.exists():
        try:
            value = float(threshold_file.read_text().strip())
            return value, f"model_threshold.txt ({value:.4f})"
        except (ValueError, OSError):
            pass  # file is there but not readable

    return None, "model.offset_ (.pkl)"

# =============================================================================
# SCORING
# Core of the detector. It takes a batch of events, runs them through the pipeline, scales them,
# and asks the model to score them.
# =============================================================================

def score_batch(events_in_queue, scaler, model, threshold, event_log_lines, alert_lines):
    """
    Scores a batch of events and fills alert_lines with anything suspicious.

    The whole function is wrapped in try/except/finally so that if anything goes wrong it shows a
    helpful error message in the live events panel instead of crashing.

    Always clears events_in_queue before returning, even if failed. Preventing re-processing of the
    same broken events.

    Returns (number_of_events_scored, number_of_anomalies_found).
    """
    if not events_in_queue:
        return 0, 0

    events_count = len(events_in_queue)
    anomalies_found = 0

    try:
        # Run the full notebook pipeline
        feature_df, events_df = build_feature_dataframe(events_in_queue)

        # Step 7: scale the features. Pass the DataFrame (not .values) so the scaler can match column names.
        scaled = scaler.transform(feature_df)

        # Step 8: score each event. More negative score = more unusual = more likely an attack.
        scores = model.score_samples(scaled)
        is_anomaly = scores < threshold
        anomalies_found = int(is_anomaly.sum())

        # Create a line for each flagged event for the display
        for idx in np.where(is_anomaly)[0]:
            event = events_df.iloc[idx] # Get the event row
            score = float(scores[idx])

            # Recover the display values (NaN is common for missing fields, use convert_str and convert_int)
            ts         = str(event.get("timestamp", ""))
            time_str   = ts[11:19] if len(ts) >= 19 else "--:--:--" # Recover the timestamp in HH:MM:SS format
            event_type = convert_str(event.get("event_type"), "?").upper()
            protocol   = convert_str(event.get("proto"), "?")
            src_ip     = convert_str(event.get("src_ip"),  "?")
            src_port   = convert_int(event.get("src_port"))
            dst_ip     = convert_str(event.get("dest_ip"), "?")
            dst_port   = convert_int(event.get("dest_port"))

            # Store the alert for later displaying
            append_lines(alert_lines, f"[{time_str}] ANOMALY score={score:.3f}  {event_type} {protocol}  {src_ip}:{src_port} -> {dst_ip}:{dst_port}", max_lines=200)

            # Try to hint what kind of attack this might be, based on the time-window features computed previously
            flows_to_dest  = convert_int(event.get("flows_to_dest_port_wndw"))
            flows_from_src = convert_int(event.get("flows_from_src_wndw"))
            unique_ports   = convert_int(event.get("unique_dest_ports_from_src_wndw"))
            unique_srcs    = convert_int(event.get("unique_srcs_to_dest_wndw"))
            tcp_rst        = convert_int(event.get("tcp_rst"))
            dns_rcode      = convert_int(event.get("dns_rcode_num"))

            if flows_to_dest > 100:
                append_lines(alert_lines, f"  -> Possible DoS: {flows_to_dest:,} connections to same destination", 200)
            if flows_from_src > 100:
                append_lines(alert_lines, f"  -> Possible Brute-force: {flows_from_src:,} connections from same source", 200)
            if unique_ports > 20:
                append_lines(alert_lines, f"  -> Possible Port scan: {unique_ports} unique destination ports", 200)
            if unique_srcs > 10:
                append_lines(alert_lines, f"  -> Possible DDoS: {unique_srcs} unique source IPs", 200)
            if tcp_rst:
                append_lines(alert_lines, "  -> TCP RST set (connection was forcibly rejected)", 200)
            if dns_rcode == 2:
                append_lines(alert_lines, "  -> DNS REFUSED (possible DNS abuse)", 200)
            elif dns_rcode == 1:
                append_lines(alert_lines, "  -> DNS NXDOMAIN (domain doesn't exist)", 200)

    except Exception as err:
        # Show the error in the live events panel. Use append_lines so that multiline messages don't break the display.
        append_lines(event_log_lines, f"[SCORING ERROR] {type(err).__name__}: {err}", max_lines=500)
        anomalies_found = 0

    finally:
        # Always clear the buffer, if fails the same broken events would be re-processed forever
        events_in_queue.clear()

    return events_count, anomalies_found

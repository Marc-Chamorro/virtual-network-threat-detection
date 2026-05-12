"""
detect.py
=========
Main entry point for the real-time anomaly detector. Handles everything shown on screen:
- the four panels, the live event feed, and the alert display.

ML and data processing live in pipeline.py.
This file reads logs, updates the UI, and decides when to score events.

How it works:
    1. A background thread connects to the logwatch Docker container and streams new lines from
       Suricata's eve.json file as they generate.
    2. The main loop reads those lines, parses them, and adds them to a buffer.
    3. When the buffer reaches 'batch_size' OR 'flush_interval' seconds pass (whichever comes
       first), the buffer is handed to a background thread that calls pipeline.score_batch().
       This keeps the UI responsive.
    4. Any anomalies found show up in the alerts panel.
    5. Press 'q' to exit cleanly.

Usage (called from ml_detect.sh):
    python3 detect.py \\
        --container         clab-virtual-env-logwatch \\
        --models            /path/to/ml/models \\
        --batch             50 \\
        --flush-interval    30 \\
        --eve-log           /var/log/suricata/eve.json \\
        --threshold         -0.5614
"""

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

# Silence warnings before anything else loads. sklearn sometimes prints warnings
warnings.filterwarnings("ignore")

import joblib

# Everything ML-related is found in pipeline.py
from pipeline import (
    EXCLUDE_TYPES,
    FEATURES,
    flatten_json,
    load_threshold,
    convert_int,
    convert_str,
    append_lines,
    score_batch,
)

# =============================================================================
# DOCKER LOG READER (background thread)
# Run in a separate thread so reading logs doesn't block the UI
# =============================================================================

def docker_log_reader(container_name, eve_log_path, line_queue, stop_event):
    """
    Connects to the container and streams new lines from eve.json.

    Runs:  docker exec <container> tail -F <eve_log_path>

    Every new line is put on the queue as:
      ("LINE",  raw_json_string)   <- a normal log line
      ("ERROR", message_string)    <- something went wrong

    The main loop reads these and processes them.
    """

    command = ["docker", "exec", container_name, "tail", "-F", eve_log_path]

    try:
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,  # hide docker's messages
            text=True,
            bufsize=1,
        )
    except FileNotFoundError:
        line_queue.put(("ERROR", "docker command not found - is Docker installed and in PATH?"))
        return

    while not stop_event.is_set():
        raw_line = process.stdout.readline()

        if not raw_line:
            # readline() returns empty string when the process exits
            if process.poll() is not None:
                line_queue.put(("ERROR", f"Container '{container_name}' stopped unexpectedly."))
                break
            time.sleep(0.05)
            continue

        raw_line = raw_line.strip()
        if raw_line:
            line_queue.put(("LINE", raw_line))

    # Make sure the docker process is stopped
    try:
        process.kill()
    except Exception:
        pass

# =============================================================================
# CURSES PANEL DRAWING
# curses is a library for drawing terminal UIs using rows/columns instead of pixels.
# =============================================================================

def draw_panel(screen, top_row, left_col, height, width, title, content_lines, text_color, show_latest_at_bottom=False):
    """
    Draws a panel with a title and text lines.

    Parameters:
    - screen                - the curses window we're drawing on
    - top_row, left_col     - where the top/left corner of this panel goes
    - height, width         - panel size (rows, columns)
    - title                 - text shown centred on the top line
    - content_lines         - the list of strings to display inside
    - text_color            - which color to use (defined in run_detector)
    - show_latest_at_bottom - if True, the most recent line appears at the bottom (like scrolling); if False, oldest at top
    """
    if height < 3 or width < 4:
        return  # panel is too small to draw anything useful

    border = curses.color_pair(1) | curses.A_BOLD

    try:
        # Draw the four corners
        screen.addch(top_row,              left_col,             "+", border)
        screen.addch(top_row,              left_col + width - 1, "+", border)
        screen.addch(top_row + height - 1, left_col,             "+", border)
        try:
            # The bottom-right corner can fail given certain weird circumstances
            screen.addch(top_row + height - 1, left_col + width - 1, "+", border)
        except curses.error:
            pass

        # Draw the horizontal border lines (top and bottom)
        for c in range(1, width - 1):
            screen.addch(top_row, left_col + c, "-", border)
            try:
                screen.addch(top_row + height - 1, left_col + c, "-", border)
            except curses.error:
                pass

        # Draw the vertical border lines (left and right sides)
        for r in range(1, height - 1):
            screen.addch(top_row + r, left_col,             "|", border)
            screen.addch(top_row + r, left_col + width - 1, "|", border)

    except curses.error:
        pass

    # Draw the title centred on the top border
    if len(title) < width - 4:
        title_col = left_col + max(2, (width - len(title)) // 2)
        try:
            screen.addstr(top_row, title_col, title, curses.color_pair(1) | curses.A_BOLD)
        except curses.error:
            pass

    # How many lines fit in the area
    available_rows = height - 2 # consider 2 borders
    available_cols = width  - 4 # consider 2 borders and 2 spaces between border and event

    # If there are no availabel lines, don't show anything
    if available_rows <= 0 or available_cols <= 0:
        return

    # Pick which lines to show
    if show_latest_at_bottom:
        lines_to_show = content_lines[-available_rows:]  # newest at bottom
    else:
        lines_to_show = content_lines[:available_rows]   # oldest at top

    for i, line in enumerate(lines_to_show):
        row = top_row + 1 + i # +1 to stay inside top border
        if row >= top_row + height - 1:
            break  # stop before bottom border
        try:
            screen.addstr(row, left_col + 2, line[:available_cols], curses.color_pair(text_color))
        except curses.error:
            pass # ignore edge screen issues


def calculate_panel_layout(terminal_rows):
    """
    Calculates the height and starting row of each of the 4 panels.

    Layout (top to bottom):
        [ Live events ] ~1/3
        [ Alerts      ] ~1/3
        [ Statistics  ] ~1/6 (min 7 rows)
        [ Model info  ] ~1/6 (min 11 rows)
    """
    MIN_STATS_HEIGHT = 7    # 5 lines of content + 2 border lines
    MIN_MODEL_HEIGHT = 11   # 9 lines of content + 2 border lines

    stats_height = max(MIN_STATS_HEIGHT, terminal_rows // 6)
    model_height = max(MIN_MODEL_HEIGHT, terminal_rows // 6)

    # Remaining rows go to the top panels
    remaining = max(terminal_rows - stats_height - model_height, 6)

    events_height = remaining // 2
    alerts_height = remaining - events_height

    return {
        "events": {"height": events_height, "top_row": 0},
        "alerts": {"height": alerts_height, "top_row": events_height},
        "stats":  {"height": stats_height,  "top_row": events_height + alerts_height},
        "model":  {"height": model_height,  "top_row": events_height + alerts_height + stats_height},
    }

# =============================================================================
# MAIN DETECTOR LOOP
# curses.wrapper() calls this function and passes the screen object.
# =============================================================================

def run_detector(screen, container_name, models_dir, cli_threshold, batch_size, flush_interval, eve_log_path):
    """
    Main loop. Runs until the user presses 'q'.

    Parameters:
    - screen                - the curses window we're drawing on
    - container_name        - container name to read logs from
    - models_dir            - directory with trained models
    - cli_threshold         - threshhold inputed (if any)
    - batch_size            - maximum events to store before processing
    - flush_interval        - maximum interval to wait before processing
    - eve_log_path          - path to Suricata eve.json inside the container

    Flow:
        1. Load the scaler and model from disk.
        2. Start the Docker reader thread.
        3. Every 0.1 seconds:
            a. Read new lines from the queue
            b. Check if it's time to score (batch full OR timeout reached)
            c. If so, hand the batch off to a background thread so the screen stays responsive
            d. Collect any results that finished scoring and update the counters
            e. Redraw the four panels
    """

    # Silence error output (stderr).
    devnull = open(os.devnull, "w")
    sys.stderr = devnull

    # -------------------------------------------------------------------------
    # Curses colour setup
    # -------------------------------------------------------------------------

    curses.curs_set(0)        # hide the cursor
    curses.start_color()
    curses.use_default_colors()

    curses.init_pair(1, curses.COLOR_CYAN,    -1)   # panel borders and titles      # -1 -> default background color
    curses.init_pair(2, curses.COLOR_RED,     -1)   # anomaly alerts
    curses.init_pair(3, curses.COLOR_GREEN,   -1)   # live events
    curses.init_pair(4, curses.COLOR_YELLOW,  -1)   # statistics
    curses.init_pair(5, curses.COLOR_MAGENTA, -1)   # model info

    screen.nodelay(True)  # don't wait for user input, continue processing

    # -------------------------------------------------------------------------
    # Load the model files
    # -------------------------------------------------------------------------

    scaler_path = Path(models_dir) / "scaler.pkl"
    model_path  = Path(models_dir) / "isolation_forest.pkl"

    if not scaler_path.exists() or not model_path.exists():
        screen.addstr(0, 0, f"ERROR: Model files not found in: {models_dir}")
        screen.addstr(1, 0, "Please run the notebook first: ml/notebooks/VNTD_ML.ipynb")
        screen.refresh()
        time.sleep(5)
        return

    scaler = joblib.load(scaler_path)
    model = joblib.load(model_path)

    # Get the anomaly threshold (see pipeline.load_threshold for priority order)
    threshold, threshold_source = load_threshold(models_dir, cli_threshold)
    if threshold is None:
        # Neither inputed on call or file had a value - fall back to what's in the model
        threshold = model.offset_
        threshold_source = f"model.offset_ ({model.offset_:.4f})"

    # -------------------------------------------------------------------------
    # State - these variables track what's happening while the detector runs
    # -------------------------------------------------------------------------

    start_time       = time.time()
    total_events     = 0                # total events processed since startup
    total_anomalies  = 0                # total anomalies found since startup
    events_in_queue  = []               # events buffered but not yet scored
    last_scored_time = time.time()

    event_log_lines = []                # lines shown in the "Live events" panel (max 500)
    alert_lines     = []                # lines shown in the "Anomaly alerts" panel (max 200)

    # Scoring threads put results here for the main loop
    scorer_results = queue.Queue()
    scoring_in_progress = False         # True while a scoring thread is running

    # -------------------------------------------------------------------------
    # Start the background Docker reader thread
    # -------------------------------------------------------------------------

    line_queue = queue.Queue()
    stop_event = threading.Event()

    threading.Thread(
        target=docker_log_reader,
        args=(container_name, eve_log_path, line_queue, stop_event),
        daemon=True,                    # thread stops when the main program exits
    ).start()

    # -------------------------------------------------------------------------
    # Main loop - runs every 0.1 seconds
    # -------------------------------------------------------------------------

    while True:

        # Check if the user pressed 'q' to quit
        key = screen.getch()
        if key in (ord("q"), ord("Q")):
            break

        terminal_rows, terminal_cols = screen.getmaxyx()
        layout = calculate_panel_layout(terminal_rows)

        # --- Read new log lines from the background thread -------------------
        # Read up to 25.000 lines per frame to keep the UI responsive.
        lines_read = 0
        try:
            while lines_read < 25000:
                msg_type, msg_data = line_queue.get_nowait()
                lines_read += 1

                if msg_type == "ERROR":
                    append_lines(event_log_lines, f"[ERROR] {msg_data}")
                    stop_event.set()  # tell the reader thread to stop

                    # Show the error briefly before exiting
                    screen.erase()
                    draw_panel(screen,
                        top_row=0, left_col=0,
                        height=terminal_rows, width=terminal_cols,
                        title="[ ERROR ]",
                        content_lines=[f"{msg_data}", "", "Press any key to exit"],
                        text_color=2
                    )
                    screen.refresh()

                    # Wait for user input so they can actually see the error
                    screen.nodelay(False)
                    screen.getch()

                    return  # exits run_detector() cleanly

                elif msg_type == "LINE":
                    # Try to parse the JSON - skip anything that isn't valid JSON
                    try:
                        raw_event = json.loads(msg_data)
                    except json.JSONDecodeError:
                        continue

                    # Skip excluded event types (e.g. "alert")
                    if raw_event.get("event_type") in EXCLUDE_TYPES:
                        continue

                    # Flatten the JSON and add it to the scoring buffer
                    flat_event = flatten_json(raw_event)
                    events_in_queue.append(flat_event)

                    # Build a short summary line for the live events panel
                    ts         = str(raw_event.get("timestamp", ""))
                    time_str   = ts[11:19] if len(ts) >= 19 else "--:--:--"
                    event_type = str(raw_event.get("event_type", "?")).upper()
                    protocol   = str(raw_event.get("proto", "?"))
                    src_ip     = convert_str(raw_event.get("src_ip"))
                    src_port   = convert_int(raw_event.get("src_port"))
                    dst_ip     = convert_str(raw_event.get("dest_ip"))
                    dst_port   = convert_int(raw_event.get("dest_port"))

                    append_lines(event_log_lines,
                        f"[{time_str}] {event_type:<8} {protocol:<5} "
                        f"{src_ip}:{src_port} -> {dst_ip}:{dst_port}")

        except queue.Empty:
            pass  # nothing new in the queue this frame, can happen

        # --- Decide if to score this frame -----------------------------------
        # Score if either condition is true:
        #  A) The buffer is full (fast during high traffic)
        #  B) Enough time passed and there is at least one event

        time_since_last = time.time() - last_scored_time
        batch_full      = len(events_in_queue) >= batch_size
        timed_out       = time_since_last >= flush_interval and len(events_in_queue) > 0

        if (batch_full or timed_out) and not scoring_in_progress:
            trigger = "batch" if batch_full else f"timeout ({int(time_since_last)}s)"
            append_lines(event_log_lines,
                f"  [scoring {len(events_in_queue)} events  trigger: {trigger}]")

            # Take up to batch_size events and remove them from the buffer so new events can keep
            # coming in while this batch is being scored in the background
            batch = events_in_queue[:batch_size]
            del events_in_queue[:batch_size]

            last_scored_time = time.time()
            scoring_in_progress = True  # block new threads until this one finishes
 
            # Run score_batch() in a thread so the UI doesn't freeze
            def _score(b):
                nonlocal scoring_in_progress
                scorer_results.put(score_batch(b, scaler, model, threshold, event_log_lines, alert_lines))
                scoring_in_progress = False  # allow the next batch to be picked up
 
            threading.Thread(target=_score, args=(batch,), daemon=True).start()
 
        # --- Collect results from any scoring threads that finished ----------
        try:
            while True:
                scored, found = scorer_results.get_nowait()
                total_events    += scored
                total_anomalies += found
        except queue.Empty:
            pass

        # --- Redraw all four panels -------------------------------------------
        screen.erase()

        # Top panel: live event stream
        draw_panel(screen,
            top_row=layout["events"]["top_row"], left_col=0,
            height=layout["events"]["height"],   width=terminal_cols,
            title="[ Live events ]",
            content_lines=event_log_lines, text_color=3,
            show_latest_at_bottom=True)

        # Middle panel: anomaly alerts
        draw_panel(screen,
            top_row=layout["alerts"]["top_row"], left_col=0,
            height=layout["alerts"]["height"],   width=terminal_cols,
            title="[ Anomaly alerts ]",
            content_lines=alert_lines, text_color=2,
            show_latest_at_bottom=True)

        # Bottom-left panel: runtime statistics
        elapsed           = int(time.time() - start_time)
        hours, remainder  = divmod(elapsed, 3600)
        minutes, seconds  = divmod(remainder, 60)
        ev_per_sec        = total_events / elapsed if elapsed > 0 else 0.0
        secs_to_flush     = max(0, flush_interval - int(time_since_last))

        draw_panel(screen,
            top_row=layout["stats"]["top_row"], left_col=0,
            height=layout["stats"]["height"],   width=terminal_cols,
            title="[ Statistics ]",
            content_lines=[
                f"  Runtime          : {hours:02d}:{minutes:02d}:{seconds:02d}",
                f"  Events processed : {total_events:,}   ({ev_per_sec:.1f} ev/s)",
                f"  Anomalies found  : {total_anomalies:,}",
                f"  Pending / batch  : {len(events_in_queue)} / {batch_size}"
                f"   (flush in {secs_to_flush}s)",
                f"  Press 'q' to quit",
            ],
            text_color=4)

        # Bottom-right panel: model information
        draw_panel(screen,
            top_row=layout["model"]["top_row"], left_col=0,
            height=layout["model"]["height"],   width=terminal_cols,
            title="[ AI Model ]",
            content_lines=[
                f"  Model            : Isolation Forest (scikit-learn)",
                f"  Trees (n_est.)   : {model.n_estimators}",
                f"  Max features     : {model.max_features}",
                f"  Contamination    : {model.contamination}",
                f"  Features used    : {len(FEATURES)}",
                f"  Threshold        : {threshold:.4f}   (source: {threshold_source})",
                f"  Batch / timeout  : {batch_size} events  OR  {flush_interval}s",
                f"  Container        : {container_name}",
                f"  Log file         : {eve_log_path}",
            ],
            text_color=5)

        screen.refresh()
        time.sleep(0.1)

    # Cleanup when the user quits
    stop_event.set()
    devnull.close()

# =============================================================================
# ENTRY POINT
# Parses command-line arguments and starts the curses UI.
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="VNTD - Real-time network anomaly detection"
    )
    parser.add_argument(
        "--container",
        required=True,
        help="Name of the container containing the logs to be analyzed (e.g. clab-virtual-env-logwatch)"
    )
    parser.add_argument(
        "--models",
        required=True,
        help="Folder containing scaler.pkl and isolation_forest.pkl"
    )
    parser.add_argument(
        "--threshold",
        type=float,
        default=None,
        help="Anomaly score threshold (optional). If not set, model_threshold.txt is tried first, then model.offset_."
    )
    parser.add_argument(
        "--batch",
        type=int,
        default=50,
        help="Score when this many events have accumulated (default: 50)"
    )
    parser.add_argument(
        "--flush-interval",
        type=int,
        default=30,
        help="Also score after this many seconds of inactivity (default: 30)"
    )
    parser.add_argument(
        "--eve-log",
        default="/var/log/suricata/eve.json",
        help="Path to eve.json inside the container"
    )

    args = parser.parse_args()

    # curses.wrapper handles setup and teardown. It also restores the terminal to normal if it crashes.
    curses.wrapper(
        run_detector,
        args.container,
        args.models,
        args.threshold,
        args.batch,
        args.flush_interval,
        args.eve_log,
    )

if __name__ == "__main__":
    main()

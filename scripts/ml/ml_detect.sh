#!/bin/sh

set -e

# === Project paths ===============================================================================

# Root directory of the project (inherited)
PRJ_DIR="$1"

# Python detection script
DETECT_SCRIPT="$PRJ_DIR/ml/realtime/detect.py"

# Directory where the trained model files are located
MODELS_DIR="$PRJ_DIR/ml/models"

# Threshold file
THRESHOLD_PATH="$MODELS_DIR/model_threshold.txt"

# === Lab configuration ===========================================================================

# Containerlab lab name (must match topology.clab.yml)
LAB_NAME="virtual-env"

# Full name of the logwatch container (format: clab-<lab>-<node>)
LOGWATCH_CONTAINER="clab-${LAB_NAME}-logwatch"

# Path to the Suricata log file inside the container
EVE_LOG="/var/log/suricata/eve.json"

# Number of events to accumulate before each model scoring
BATCH=5000

# Maximum time between processing a batch of files
FLUSH_INTERVAL=30

# === Check Python is available ===================================================================
if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] python3 is not installed or not found in PATH"
    exit 0
fi

# === Virtual environment setup ===================================================================

VENV_DIR="$PRJ_DIR/venv"
PYTHON="$VENV_DIR/bin/python"
PIP="$VENV_DIR/bin/pip"

# Create venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "[INFO] Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Ensure pip exists (sanity check)
if [ ! -f "$PIP" ]; then
    echo "[WARN] Broken venv detected. Recreating..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

# Upgrade pip (recommended)
echo "[INFO] Ensuring pip is up to date..."
"$PYTHON" -m pip install --upgrade pip --quiet

# === Install dependencies inside venv ============================================================

if ! "$PYTHON" -c "import scikit-learn, pandas, numpy, joblib" >/dev/null 2>&1; then
    echo "[INFO] Installing Python dependencies in venv..."

    REQS="$PRJ_DIR/ml/requirements.txt"

    if [ -f "$REQS" ]; then
        "$PIP" install -r "$REQS" --quiet
    else
        "$PIP" install scikit-learn pandas numpy joblib --quiet
    fi
fi

# === Banner ======================================================================================
 
echo ""
echo "============================================================"
echo "  VNTD - Real-time anomaly detection"
echo "============================================================"
echo ""
echo "  Container  : $LOGWATCH_CONTAINER"
echo "  Log        : $EVE_LOG"
echo "  Models     : $MODELS_DIR"
echo "  Batch size : $BATCH_SIZE events"
echo ""

# === Checks ======================================================================================

# Check that model files exist
if [ ! -f "$MODELS_DIR/scaler.pkl" ] || [ ! -f "$MODELS_DIR/isolation_forest.pkl" ]; then
    echo ""
    echo "[ERROR] Model files not found in: $MODELS_DIR"
    echo ""
    exit 0
fi

echo "[OK] Model files found"

# Check that threshold file exists
if [ ! -f "$THRESHOLD_PATH" ]; then
    echo ""
    echo "[ERROR] Threshold file not found: $THRESHOLD_PATH"
    echo ""
    exit 0
fi

# Read threshold value
THRESHOLD_VALUE=$(cat "$THRESHOLD_PATH")

echo "[OK] Threshold loaded: $THRESHOLD_VALUE"

# Container check
if ! docker ps --format '{{.Names}}' | grep -q "^${LOGWATCH_CONTAINER}$"; then
    echo ""
    echo "[ERROR] Container not running: $LOGWATCH_CONTAINER"
    echo ""
    echo "Active containers:"
    docker ps --format "  - {{.Names}}" 2>/dev/null || echo " "
    echo ""
    exit 0
fi


echo "[OK] Container '$LOGWATCH_CONTAINER' found"
echo ""

# === Start =======================================================================================

echo ""
echo "  Starting the interface... (press 'q' to exit)"
echo ""
sleep 1

# --- Launch the detector ---
"$PYTHON" "$DETECT_SCRIPT" \
    --container         "$LOGWATCH_CONTAINER" \
    --models            "$MODELS_DIR" \
    --flush-interval    "$FLUSH_INTERVAL" \
    --batch             "$BATCH" \
    --eve-log           "$EVE_LOG" \
    --threshold         "$THRESHOLD_VALUE"

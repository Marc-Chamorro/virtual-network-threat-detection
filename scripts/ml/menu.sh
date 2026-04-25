#!/bin/sh

set -e

# Recover the projects directory from the parent script
PRJ_DIR="$1"

# Find the current directory where this script is found at
CURRENT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

menu() {
    echo ""
    echo "===== ML Anomaly Detection Menu ====="
    echo "1) > Start real-time detection"
    echo "2) > Back"
    echo "====================================="
    printf "Choose an option: "
}

run_script() {
    echo ""
    echo ">>> Running: $1"
    echo "--------------------------------"
    sh "$CURRENT_DIR/$1" "$PRJ_DIR"
    echo "--------------------------------"
    echo ">>> Finished: $1"
}

while true; do
    menu
    read choice

    case "$choice" in
        1) run_script ml_detect.sh ;;
        2) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
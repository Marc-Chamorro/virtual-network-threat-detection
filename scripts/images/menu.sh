#!/bin/sh

set -e

PRJ_DIR="$1"
CURRENT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

menu() {
    echo ""
    echo "===== Image Control Menu ====="
    echo "1) > Create images"
    echo "2) > Import images (.xz)"
    echo "3) > Delete images"
    echo "4) > Display images"
    echo "5) > Back"
    echo "=============================="
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
        1) run_script create.sh ;;
        2) run_script import.sh ;;
        3) run_script delete.sh ;;
        4) run_script display.sh ;;
        5) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
#!/bin/sh

set -e

IMAGES_SCRIPTS_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

menu() {
    echo ""
    echo "===== Image Control Menu ====="
    echo "1) > Create images"
    echo "2) > Delete images"
    echo "3) > Display images"
    echo "4) > Back"
    echo "=============================="
    printf "Choose an option: "
}

run_script() {
    echo ""
    echo ">>> Running: $1"
    echo "--------------------------------"
    sh "$IMAGES_SCRIPTS_DIR/$1"
    echo "--------------------------------"
    echo ">>> Finished: $1"
}

while true; do
    menu
    read choice

    case "$choice" in
        1) run_script create.sh ;;
        2) run_script delete.sh ;;
        3) run_script display.sh ;;
        4) exit 0 ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
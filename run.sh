#!/bin/sh

# Stop the script on error, do not proceed with the execution
set -e

# Get the absolute path of the project root directory
PRJ_DIR=$(dirname "$(readlink -f "$0")")
SCRIPTS_DIR="$PRJ_DIR/scripts"

# Define paths to the sub-menus
S_MENU_IMAGES="$SCRIPTS_DIR/images/menu.sh"
S_MENU_CLAB="$SCRIPTS_DIR/clab/menu.sh"
S_MENU_ATTACKS="$SCRIPTS_DIR/attacks/menu.sh"
S_MENU_ML="$SCRIPTS_DIR/ml/menu.sh"

menu() {
    echo ""
    echo "===== Project Control Menu ====="
    echo "1) → Image control"
    echo "2) → Topology control"
    echo "3) → Simulate attacks"
    echo "4) → Anomaly detection (ML)"
    echo "5) > Exit"
    echo "================================"
    printf "Choose an option: "
}

handle_input() {
    case "$1" in
        1) sh "$S_MENU_IMAGES" "$PRJ_DIR" ;;
        2) sh "$S_MENU_CLAB" "$PRJ_DIR" ;;
        3) sh "$S_MENU_ATTACKS" "$PRJ_DIR" ;;
        4) sh "$S_MENU_ML" "$PRJ_DIR" ;;
        5) echo "Exiting."
           exit 0 ;;
        *) echo "Invalid option." ;;
    esac
}

# Main application loop
while true; do
    menu
    read choice
    handle_input "$choice"    
done

#!/bin/sh

set -e

# Recover the projects directory from the parent script
PRJ_DIR="$1"

# Find the current directory where this script is found at
CURRENT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Find the location of the topology definition files
TOPOLOGY_DIR="$PRJ_DIR/labs"

menu() {
    echo ""
    echo "===== Topology Control Menu ====="
    echo "1) > Deploy topology"
    echo "2) > Destroy topology"
    echo "3) > Display available topologies"
    echo "4) > Back"
    echo "================================"
    printf "Choose an option: "
}

run_script() {
    echo ""
    echo ">>> Running: $1"
    echo "--------------------------------"
    sh "$CURRENT_DIR/$1" "$TOPOLOGY_DIR"
    echo "--------------------------------"
    echo ">>> Finished: $1"
}

# Menu loop
while true; do
    menu
    read choice

    case "$choice" in
        1) run_script deploy.sh ;;
        2) run_script destroy.sh ;;
        3) run_script display.sh ;;
        4) exit 0 ;;    # Return to the main menu
        *) echo "Invalid option." ;;
    esac
done
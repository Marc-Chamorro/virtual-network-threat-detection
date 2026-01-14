#!/bin/sh

set -e

TOPO_SCRIPTS_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

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
    sh "$TOPO_SCRIPTS_DIR/$1"
    echo "--------------------------------"
    echo ">>> Finished: $1"
}

while true; do
    menu
    read choice

    case "$choice" in
        1) run_script deploy.sh ;;
        2) run_script destroy.sh ;;
        3) run_script display.sh ;;
        4) exit 0 ;;
        *)
            echo "Invalid option."
            ;;
    esac
done
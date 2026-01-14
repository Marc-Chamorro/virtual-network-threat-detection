#!/bin/sh

# Stop the script on error, do not proceed with the execution
set -e

PRJ_DIR=$(dirname "$(readlink -f "$0")")         # https://dev.to/bobbyiliev/how-to-get-the-directory-where-a-bash-script-is-located-em3#:~:text=The%20simplest%20way%20to%20get,or%20just%20the%20script%20name.
SCRIPTS_DIR="$PRJ_DIR/scripts"

S_MENU_IMAGES="$SCRIPTS_DIR/images/menu.sh"
S_MENU_CLAB="$SCRIPTS_DIR/clab/menu.sh"

menu() {
    echo ""
    echo "===== Project Control Menu ====="
    echo "1) → Image control"
    echo "2) → Topology control"
    echo "3) > Exit"
    echo "================================"
    printf "Choose an option: "
}

while true; do
    menu
    read choice

    case "$choice" in
        1) sh $S_MENU_IMAGES ;;
        2) sh $S_MENU_CLAB ;;
        3)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
done

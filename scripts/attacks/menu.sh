#!/bin/sh

set -e

# Find the current directory where this script is found at
CURRENT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# Check if there is any running lab
check_running_topologies() {
    echo ""
    echo "Checking for running containerlab topologies..."
    RUNNING_JSON=$(clab inspect --all -f json)

    if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
        echo "No running topologies detected."
        exit 0
    fi
}

# Find the attacker node name
find_container_name() {
    # Find container named clab-*-attacker
    # | true -> required due to 'set -e' being set, if no result the process would exit
    
    # CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep '^clab-.*-attacker$' || true)

    CONTAINER_NAME=$(docker ps --format '{{.Names}}' \
        | grep '^clab-.*-attacker$' \
        | grep -v 'router\|switch' \
        | head -n 1)

    echo "$CONTAINER_NAME"

    # Check if string is of 0 length
    if [ -z "$CONTAINER_NAME" ]; then
        echo "Topology is running but no attacker container was found."
        echo "Expected container pattern: clab-*-attacker"
        echo "E.g. 'clab-virtual-env-attacker'"
        exit 1
    fi

    echo "Detected attacker container: $CONTAINER_NAME"
}

list_scripts() {

    echo ""
    echo "===== Attacker Control Menu ====="
    i=0

    # Iterate all script files
    for script in "$CURRENT_DIR"/*.sh ; do

        name=$(basename "$script")

        # Skip itself
        if [ "$name" = "$(basename "$0")" ]; then
            continue
        fi

        if [ -f "$script" ]; then
            i=$((i+1))

            # Ask the script for its menu name
            SCRIPT_NAME=$(sh "$script" -n)

            echo "$i) > $SCRIPT_NAME"

            # Store script path in a dynamically created variable
            eval "script_$i=\$script"
        fi

    done

    if [ "$i" = 0 ]; then
        echo "No attack scripts found."
        exit 1
    fi

    # Back option
    i=$((i+1))
    echo "$i) > Back"

    echo "================================"

    TOTAL_OPTIONS=$i
}

run_script() {

    # Recover the select script selected by the user
    eval "selected_script=\$script_$1"

    echo ""
    echo ">>> Running: $(basename "$selected_script")"
    echo "--------------------------------"

    sh "$selected_script" "$CONTAINER_NAME"

    echo "--------------------------------"
    echo ">>> Finished: $(basename "$selected_script")"
}

# Ensure a topology is running
check_running_topologies

# Recover the name from the container where attacks are to be launched from
find_container_name

# Menu loop
while true; do
    list_scripts

    echo "Choose an option (1-$TOTAL_OPTIONS): " 
    read choice

    case "$choice" in
        $i) exit 0 ;;
        ''|*[!0-9]*) echo "Invalid option." ;;
        *)
            if [ "$choice" -ge 1 ] && [ "$choice" -lt "$TOTAL_OPTIONS" ]; then
                run_script "$choice"
            else
                echo "Number out of range"
            fi ;;
    esac
done
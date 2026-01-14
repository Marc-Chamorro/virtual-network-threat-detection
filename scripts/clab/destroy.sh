#!/bin/sh

set -e

PRJ_DIR="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
TOPOLOGY_DIR="$PRJ_DIR/labs"

# CHECK IF ANY TOPO IS RUNNING

echo "Checking for running containerlab topologies..."

RUNNING_JSON=$(clab inspect --all -f json)

if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
    echo "No running topologies detected."
    exit 0
else
    echo "One or more topologies are currently running:"
    clab inspect --all
fi

# CREATE TOPOLOGY LIST

set --

echo "Available labs to destroy:"
i=0

for topo in $TOPOLOGY_DIR/*.clab.yml ; do
    if [ -f "$topo" ]; then
        i=$((i+1))
        echo "$i) $(basename "$topo")"
        set -- "$@" "$topo"
    fi
done

if [ "$i" = 0 ]; then
    echo "No labs found at $TOPOLOGY_DIR"
    exit 1
fi

i=$((i+1))
echo "$i) > Back"

# MENU

while true; do
    echo "Select a lab to destroy (1-$i): " 
    read choice

    case "$choice" in
        $i)
            exit 0 ;;
        ''|*[!0-9]*)
            echo "Invalid option." ;;
        *)
            if [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
                eval "selected_topo=\"\$$choice\""
                break;
            else
                echo "Number out of range"
            fi ;;
    esac
done

# DESTROY

echo "Destroying topology..."

clab destroy -t "$selected_topo"
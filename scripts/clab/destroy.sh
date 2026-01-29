#!/bin/sh

set -e

TOPOLOGY_DIR="$1"

# Check if there are actually labs to destroy
check_running_topologies() {
    echo "Checking for running containerlab topologies..."
    RUNNING_JSON=$(clab inspect --all -f json)

    if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
        echo "No running topologies detected."
        exit 0
    else
        echo "One or more topologies are currently running:"
        clab inspect --all
    fi
}

# Check topology definition files to use as destroy target
list_topologies_to_destroy() {
    echo "Available labs to destroy:"
    i=0

    for topo in $TOPOLOGY_DIR/*.clab.yml ; do
        if [ -f "$topo" ]; then
            i=$((i+1))
            echo "$i) $(basename "$topo")"
            eval "topo_$i=\$topo"
        fi
    done

    if [ "$i" = 0 ]; then
        echo "No labs found at $TOPOLOGY_DIR"
        exit 1
    fi

    i=$((i+1))
    echo "$i) > Back"

    TOTAL_OPTIONS=$i
}

check_running_topologies
while true; do
    list_topologies_to_destroy

    echo "Select a lab to destroy (1-$TOTAL_OPTIONS): " 
    read choice

    case "$choice" in
        $i) exit 0 ;;
        ''|*[!0-9]*) echo "Invalid option." ;;
        *)
            if [ "$choice" -ge 1 ] && [ "$choice" -lt "$TOTAL_OPTIONS" ]; then
                eval "selected_topo=\$topo_$choice"
                break;
            else
                echo "Number out of range"
            fi ;;
    esac
done

echo "Selected topology: $selected_topo"
echo "Destroying topology..."

# Removes containers and virtual wires defined in the selected topology
clab destroy -t "$selected_topo"
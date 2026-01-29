#!/bin/sh

set -e

# Target directory where .clab.yml files are located
TOPOLOGY_DIR="$1"

# Check if any topologies are currently running
check_running_topologies() {
    echo "Checking for running containerlab topologies..."

    # Inspect all running labs in JSON format to check if empty
    RUNNING_JSON=$(clab inspect --all -f json)

    if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
        echo "No running topologies detected."
    else
        echo "One or more topologies are currently running:"
        clab inspect --all
    fi
}

# List available topologies and store them dynamically for selection
list_topologies() {
    echo "Available labs: "
    i=0

    # Iterate all topology files
    for topo in $TOPOLOGY_DIR/*.clab.yml ; do
        # Check if the element is actualy a file
        if [ -f "$topo" ]; then
            i=$((i+1))
            echo "$i) $(basename "$topo")"
            # Dynamically create variables (e.g., topo_1, topo_2)
            eval "topo_$i=\$topo"
        fi
    done

    if [ "$i" = 0 ]; then
        echo "No labs found at $TOPOLOGY_DIR"
        exit 1
    fi

    # Add the back option
    i=$((i+1))
    echo "$i) > Back"

    TOTAL_OPTIONS=$i
}

check_running_topologies
while true; do
    list_topologies

    echo "Select a lab to deploy (1-$TOTAL_OPTIONS): " 
    read choice

    case "$choice" in
        $i) exit 0 ;;
        ''|*[!0-9]*) echo "Invalid option." ;; # Ensure the value inserted is actually a number before processing
        *)
            if [ "$choice" -ge 1 ] && [ "$choice" -lt "$TOTAL_OPTIONS" ]; then
                # Recover the value of the dynamic variable
                eval "selected_topo=\$topo_$choice"
                break;
            else
                echo "Number out of range"
            fi ;;
    esac
done

echo "Selected topology: $selected_topo"
echo "Deploying topology..."

# Deploy the selected topology
clab deploy --topo "$selected_topo"
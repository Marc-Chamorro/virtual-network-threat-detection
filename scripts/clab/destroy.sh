#!/bin/sh

set -e

TOPOLOGY_DIR="$1"
LOGWATCH_MACHINE="logwatch"

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

cleanup_isolation_rules() {
    echo "Cleaning isolation rules..."

    # Get the lab name from the topology YAML file (not the filename)
    LAB_NAME=$(grep -E '^name:' "$selected_topo" | awk '{print $2}' | tr -d '"'\''')
    LOGWATCH_CONTAINER="clab-${LAB_NAME}-${LOGWATCH_MACHINE}"

    LOGWATCH_IP=""

    # Only try to get IP if container is still running
    if docker ps | grep -q "$LOGWATCH_CONTAINER"; then
        echo "Device $LOGWATCH_CONTAINER found"

        # Retrieve the container IP
        LOGWATCH_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$LOGWATCH_CONTAINER" 2>/dev/null || true)
    else
        echo "Device $LOGWATCH_CONTAINER not found"
    fi

    # Remove Logwatch specific rules if we have the IP (maybe the device is not available on the topology)
    if [ -n "$LOGWATCH_IP" ]; then
        iptables -D FORWARD -s "$LOGWATCH_IP" ! -o br+ -j ACCEPT 2>/dev/null || true
        iptables -D FORWARD -d "$LOGWATCH_IP" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
        iptables -t nat -D POSTROUTING -s "$LOGWATCH_IP" ! -o br+ -j MASQUERADE 2>/dev/null || true

        echo "Logwatch rules removed"
    else
        echo "Skipping logwatch-specific cleanup"
    fi

    # Remove general rules
    iptables -D FORWARD -i br+ -o br+ -j ACCEPT 2>/dev/null || true
    iptables -D FORWARD -i br+ ! -o br+ -j DROP 2>/dev/null || true

    echo "Cleanup complete"
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

cleanup_isolation_rules

# Removes containers and virtual wires defined in the selected topology
clab destroy -t "$selected_topo"

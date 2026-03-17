#!/bin/sh

set -e

# Target directory where .clab.yml files are located
TOPOLOGY_DIR="$1"
LOGWATCH_MACHINE="logwatch"

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

apply_isolation_rules() {
    echo "Applying isolation rules..."

    # Get the lab name from the topology YAML file (not the filename)
    # grep -> from the file, look for the line: name: virtual-env
    # awk -> split by whitespace, get the second part: virtual-env
    # tr -> trim unnecessary characters like " or ': virtual-env (this case the same)
    LAB_NAME=$(grep -E '^name:' "$selected_topo" | awk '{print $2}' | tr -d '"'\''')

    # Build the container name for the logwatch service
    LOGWATCH_CONTAINER="clab-${LAB_NAME}-${LOGWATCH_MACHINE}"

    LOGWATCH_IP=""

    # Try to retrieve the container IP (if it exists)
    if docker ps | grep -q "$LOGWATCH_CONTAINER"; then
        echo "Device $LOGWATCH_CONTAINER found"

        # Try to retrieve the container IP
        for i in 1 2 3; do
            LOGWATCH_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
                "$LOGWATCH_CONTAINER" 2>/dev/null || true)
            [ -n "$LOGWATCH_IP" ] && break
            sleep 2
        done

        # If couldn't get the IP, inform
        if [ -z "$LOGWATCH_IP" ]; then
            echo "Warning: Could not retrieve IP for $LOGWATCH_CONTAINER"
        else
            echo "Logwatch IP: $LOGWATCH_IP"
        fi
    else
        echo "Device $LOGWATCH_CONTAINER not found"
    fi

    # CLEANUP OLD RULES
    # These commands try to delete rules if they already exist
    # Errors are ignored (rule may have not been applied yet)
    iptables -D FORWARD -s "$LOGWATCH_IP" ! -o br+ -j ACCEPT 2>/dev/null || true
    iptables -D FORWARD -d "$LOGWATCH_IP" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    iptables -D FORWARD -i br+ -o br+ -j ACCEPT 2>/dev/null || true
    iptables -D FORWARD -i br+ ! -o br+ -j DROP 2>/dev/null || true

    # ADD RULES IN ORDER
    # -I FORWARD X allows to insert rules in a specific position / priority

    # 1. Allow traffic between lab bridges (internal lab communication)
    iptables -I FORWARD 1 -i br+ -o br+ -j ACCEPT

    # 2. Block any traffic leaving the lab bridges to outside
    iptables -I FORWARD 2 -i br+ ! -o br+ -j DROP

    # LOGWATCH RULES (only if available)
    if [ -n "$LOGWATCH_IP" ]; then
        # 3. Allow logwatch out + return traffic as priority 1, so the drop does not affect this machine
        iptables -I FORWARD 1 -s "$LOGWATCH_IP" ! -o br+ -j ACCEPT
        iptables -I FORWARD 1 -d "$LOGWATCH_IP" -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

        # 4. NAT for logwatch (check if exists with -C, if not add it)
        iptables -t nat -C POSTROUTING -s "$LOGWATCH_IP" ! -o br+ -j MASQUERADE 2>/dev/null || \
        iptables -t nat -A POSTROUTING -s "$LOGWATCH_IP" ! -o br+ -j MASQUERADE
    
        echo "Logwatch rules applied"
    else
        echo "Skipping logwatch-specific rules"
    fi

    echo "Isolation applied successfully"
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

apply_isolation_rules

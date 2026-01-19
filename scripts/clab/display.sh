#!/bin/sh

set -e

TOPOLOGY_DIR="$1"

list_topologies() {
    echo "Available labs: "

    i=1
    for topo in $TOPOLOGY_DIR/*.clab.yml ; do
        if [ -f "$topo" ]; then
            echo "$i) $(basename "$topo")"
            i=$((i+1))
        fi
    done
}

list_running_topologies() {
    echo "Running labs: "
    RUNNING_JSON=$(clab inspect --all -f json)

    if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
        echo "No running topologies detected."
    else
        echo "One or more topologies are currently running:"
        clab inspect --all
    fi
}

list_topologies
list_running_topologies
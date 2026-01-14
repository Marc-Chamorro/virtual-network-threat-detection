#!/bin/sh

set -e

PRJ_DIR="$(cd "$(dirname "$(readlink -f "$0")")/../.."  && pwd)"
TOPOLOGY_DIR="$PRJ_DIR/labs"

echo "Available labs: "

i=1

# Ensure the element has .clab.yml type
for topo in $TOPOLOGY_DIR/*.clab.yml ; do
    if [ -f "$topo" ]; then
        echo "$i) $(basename "$topo")"
        i=$((i+1))
    fi
done

echo
echo "Running labs: "

RUNNING_JSON=$(clab inspect --all -f json)

if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
    echo "No running topologies detected."
else
    echo "One or more topologies are currently running:"
    clab inspect --all
fi
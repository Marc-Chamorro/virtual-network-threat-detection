#!/bin/sh

set -e

PRJ_DIR="$(cd "$(dirname "$(readlink -f "$0")")/../.."  && pwd)"
TOPOLOGY_DIR="$PRJ_DIR/labs"

# CHECK IF ANY TOPO IS RUNNING

echo "Checking for running containerlab topologies..."

RUNNING_JSON=$(clab inspect --all -f json)

if [ "$RUNNING_JSON" = "{}" ] || [ -z "$RUNNING_JSON" ]; then
    echo "No running topologies detected."
else
    echo "One or more topologies are currently running:"
    clab inspect --all
fi

# CREATE TOPOLOGY LIST

# Necessary to dinamically store the topologies somewhere
# Idea from: 
    # https://stackoverflow.com/questions/35385962/arrays-in-a-posix-compliant-shell
    # https://www.reddit.com/r/commandline/comments/y40m5j/what_does_set_do/
set -- # Everything afterwards is not an option/argument

echo "Available labs: "

i=0

for topo in $TOPOLOGY_DIR/*.clab.yml ; do
    if [ -f "$topo" ]; then
        i=$((i+1))
        echo "$i) $(basename "$topo")"
        set -- "$@" "$topo" # Add element to positional parameter
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
    echo "Select a lab to deploy (1-$i): " 
    read choice

    case "$choice" in
        $i)
            exit 0 ;;
        ''|*[!0-9]*)
            echo "Invalid option." ;;
        *)
            if [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
                # https://unix.stackexchange.com/questions/413268/better-way-to-retrieve-n-th-index-positional-parameter-value-in-ash-then-ev
                eval "selected_topo=\"\$$choice\""
                break;
            else
                echo "Number out of range"
            fi ;;
    esac
done

# DEPLOY
echo
echo "Deploying topology..."
echo

# Deploy the topology
clab deploy --topo "$selected_topo"


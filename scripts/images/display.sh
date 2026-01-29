#!/bin/sh

set -e

# Filter images only created for this project
IMAGES=$(docker images --filter "reference=*_vntd" -q)

if [ -n "$IMAGES" ]; then
    echo "Project images (*_vntd):"
    docker image ls --filter "reference=*_vntd"
else
    echo "No project images (*_vntd) were found"
fi

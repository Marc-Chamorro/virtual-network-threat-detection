#!/bin/sh

set -e

IMAGES=$(docker images --filter "reference=*_vntd" -q)

if [ -n "$IMAGES" ]; then
    docker image ls --filter "reference=*_vntd"
else
    echo "No project images (*_vntd) were found"
fi

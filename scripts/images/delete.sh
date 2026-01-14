#!/bin/sh

set -e

# Get all the project images
IMAGES=$(docker images --filter "reference=*_vntd" -q)

# Force delete the found images
if [ -n "$IMAGES" ]; then
    docker rmi -f $IMAGES
else
    echo "No images were deleted"
fi

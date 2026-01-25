#!/bin/sh

set -e

# CRRNT_DIR="$(dirname "$(readlink -f "$0")")"
# PARENT_DIR="$(cd $CRRNT_DIR/.. )"
# PRJ_DIR="$($PARENT_DIR && pwd)"

PRJ_DIR="$1"
IMAGES_DIR="$PRJ_DIR/docker/build"

# Get all the directories in 'docker'
for directory in $IMAGES_DIR/* ; do
    BASENAME="$(basename "$directory")"

    # If such is a file and not a directory, skip it
    if [ -d "$directory" ] && [ "$(echo "$BASENAME" | cut -c1)" != "_" ]; then

        IMAGE_NAME="${BASENAME}_vntd"

        echo "Building image: $IMAGE_NAME"

        # Create the images
        docker build -t "$IMAGE_NAME" "$directory"

    fi
done
#!/bin/sh

set -e

PRJ_DIR="$1"
IMAGES_DIR="$PRJ_DIR/docker/build"

# Get all the directories in 'docker'
for directory in $IMAGES_DIR/* ; do
    BASENAME="$(basename "$directory")"

    # If such element is a file and not a directory and does not start with the character "_", skip it
    if [ -d "$directory" ] && [ "$(echo "$BASENAME" | cut -c1)" != "_" ]; then

        # Create the new image name
        IMAGE_NAME="${BASENAME}_vntd"

        echo "Building image: $IMAGE_NAME"

        # Create the image
        docker build -t "$IMAGE_NAME" "$directory"
    fi
done
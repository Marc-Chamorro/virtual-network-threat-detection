#!/bin/sh

set -e

PRJ_DIR="$1"
IMPORT_DIR="$PRJ_DIR/docker/import"

if [ ! -d "$IMPORT_DIR" ]; then
    echo "Import directory not found."
    exit 0
fi

# Check for all import files with specified format type
for file in $IMPORT_DIR/*.tar.xz; do
    if [ -f "$file" ]; then
        # Extract the name until the first colon "-"
        IMAGE_NAME=$(basename "$file" | cut -d'-' -f1)

        # Lowercase the name of the image
        IMAGE_NAME="$(echo "$IMAGE_NAME" | tr '[:upper:]' '[:lower:]')_vntd"

        echo "Importing image: $IMAGE_NAME from $file"

        # Import the image into docker
        docker import "$file" "$IMAGE_NAME"
    fi
done
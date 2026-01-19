#!/bin/sh

set -e

PRJ_DIR="$1"
IMPORT_DIR="$PRJ_DIR/docker/import"

# https://containerlab.dev/manual/kinds/ceos/
# can for .xz files
for file in $IMPORT_DIR/*.xz; do
    if [ -f "$file" ]; then
        # extract the name until - # https://stackoverflow.com/questions/20348097/bash-extract-string-before-a-colon
        IMAGE_NAME=$(basename "$file" | cut -d'-' -f1)

        # https://stackoverflow.com/questions/2264428/how-to-convert-a-string-to-lower-case-in-bash
        IMAGE_NAME="$(echo "$IMAGE_NAME" | tr '[:upper:]' '[:lower:]')_vntd"

        echo "Importing image: $IMAGE_NAME from $file"

        docker import "$file" "$IMAGE_NAME"
    fi
done
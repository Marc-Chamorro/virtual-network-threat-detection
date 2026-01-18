#!/bin/sh
set -e

PRJ_DIR="$(cd "$(dirname "$(readlink -f "$0")")/../../.." && pwd)"
IMPORT_DIR="$PRJ_DIR/docker/import"
VRNETLAB_DIR="$PRJ_DIR/docker/vrnetlab/juniper/vjunosswitch"

echo "Importing vJunos-switch via vrnetlab"

i=0

for fl in $IMPORT_DIR/*.qcow2 ; do
    if [ -f "$fl" ]; then
        i=$((i+1))
        FILE=$fl
    fi
done

if [ "$i" = 0 ]; then
    echo "No vJunos-switch qcow2 image found at $IMPORT_DIR"
    exit 1
fi

if [ ! -d "$VRNETLAB_DIR" ]; then
    echo "vrnetlab vjunosswitch directory not found: $VRNETLAB_DIR"
    exit 1
fi

DEST_FILE="$VRNETLAB_DIR/$(basename "$FILE")"
if [ -f "$DEST_FILE" ]; then
    echo "Image already exists in directory: $(basename "$FILE")"
else
    echo "Copying image to vrnetlab directory..."
    cp "$FILE" "$VRNETLAB_DIR/"
fi

cd "$VRNETLAB_DIR"

make -C "$VRNETLAB_DIR"

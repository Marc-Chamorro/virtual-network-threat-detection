#!/bin/sh

set -e

# ./port_scanning.sh clab-virtual-env-attacker
# ./port_scanning.sh clab-virtual-env-attacker 172.16.30.2

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "Port scanning | nmap"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target]"
    exit 0
fi

ATTACKER_CONTAINER="$1"
TARGET="${2:-enterprise.com}"             # Default to enterprise.com if no target is given

# https://www.kali.org/tools/nmap/
echo "================================"
echo "Attack: Port scan (Nmap SYN & UDP scan)"
echo "Target: $TARGET"
echo "Attacker container: $ATTACKER_CONTAINER"
echo "================================"

# -sS           -> TCP SYN port scan (Default)
# -sU           -> UDP port scan
# -sV           -> Service and version detection on ports
# -sC           -> Run with default scripts
# -O            -> OS detection
# -p-           -> Port scan all ports (1–65535)
# --top-ports X -> Scan the X most common ports
# -T4           -> Timing (0–5), higher is faster but more detectable
# -v            -> Output progress (verbose)
# --reason      -> Display the reason a port is in a particular state

echo "--- Running TCP scan ---"
docker exec "$ATTACKER_CONTAINER" nmap -sS -sV -sC -O -p- -T4 -v --reason "$TARGET"

echo "--- Running UDP scan (top 100 ports) ---"
docker exec "$ATTACKER_CONTAINER" nmap -sU -sV --top-ports 100 -T4 -v --reason "$TARGET"

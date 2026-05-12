#!/bin/sh

# generate_benign.sh
# Generates BENIGN-ONLY traffic for Suricata EVE JSON dataset collection
# Use this to produce clean normal traffic samples for AI model training
# Compatible with both topology.clab.yml (full) and topology_reduced.clab.yml (reduced)

# If called with -n, return the menu name (compatible with the attacks menu system)
if [ "$1" = "-n" ]; then
    echo "[+] Dataset generation | Benign traffic only"
    exit 0
fi

# =============================================================================
# Container names
# =============================================================================

LAB="clab-virtual-env"

ATTACKER="$LAB-attacker"
BENIGN="$LAB-benign"          # olivia

# Always present (reduced + full topology)
PC_V50_1="$LAB-pc-vlan50-1"   # alice
PC_V60_1="$LAB-pc-vlan60-1"   # emma
PC_ADMIN="$LAB-pc-admin"      # lois

# Only present in the full topology
PC_V50_2="$LAB-pc-vlan50-2"   # barry
PC_V60_2="$LAB-pc-vlan60-2"   # clark

LOGWATCH="$LAB-logwatch"
EVE_LOG="/var/log/suricata/eve.json"

ATTACKS_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# =============================================================================
# Optional device detection
# =============================================================================

is_running() {
    docker ps --format "{{.Names}}" | grep -q "^$1$"
}

HAS_PC_V50_2=0
HAS_PC_V60_2=0

if is_running "$PC_V50_2"; then HAS_PC_V50_2=1; fi
if is_running "$PC_V60_2"; then HAS_PC_V60_2=1; fi

# =============================================================================
# Helpers
# =============================================================================

log() {
    echo ""
    echo "=========================================="
    echo "  $1"
    echo "  $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
}

status() {
    # status <container> <label>
    if is_running "$1"; then
        echo "  [+] $1  ($2)"
    else
        echo "  [-] $1  ($2)  <-- not found, commands will be skipped"
    fi
}

# =============================================================================
# Environment summary
# =============================================================================

log "ENVIRONMENT"

echo ""
echo "  Required devices:"
status "$ATTACKER"  "kali"
status "$BENIGN"    "olivia"
status "$PC_V50_1"  "alice"
status "$PC_V60_1"  "emma"
status "$PC_ADMIN"  "lois"
echo ""
echo "  Optional devices (full topology only):"
status "$PC_V50_2"  "barry"
status "$PC_V60_2"  "clark"
echo ""

sleep 2

# =============================================================================
# PHASE 1 - Normal baseline traffic
# =============================================================================

log "PHASE 1 - Normal baseline traffic"

# 1.1 - DNS queries
echo "--- 1.1 DNS queries ---"
docker exec "$PC_V50_1" nslookup internet.com || true
docker exec "$PC_V60_1" nslookup internet.com || true
docker exec "$PC_ADMIN" nslookup internet.com || true
if [ "$HAS_PC_V50_2" = "1" ]; then docker exec "$PC_V50_2" nslookup internet.com || true; fi
if [ "$HAS_PC_V60_2" = "1" ]; then docker exec "$PC_V60_2" nslookup internet.com || true; fi
sleep 3

# 1.2 - Web browsing from inside (enterprise -> internet)
echo "--- 1.2 Web browsing from inside ---"
docker exec "$PC_V50_1" wget -q -O /dev/null http://internet.com || true
docker exec "$PC_V60_1" wget -q -O /dev/null http://internet.com || true
docker exec "$PC_ADMIN" curl -s -o /dev/null http://internet.com || true
if [ "$HAS_PC_V50_2" = "1" ]; then docker exec "$PC_V50_2" wget -q -O /dev/null http://internet.com || true; fi
if [ "$HAS_PC_V60_2" = "1" ]; then docker exec "$PC_V60_2" wget -q -O /dev/null http://internet.com || true; fi
sleep 3

# 1.3 - Web browsing from outside (benign/attacker -> enterprise)
echo "--- 1.3 Web browsing from outside ---"
docker exec "$BENIGN"   wget -q -O /dev/null http://enterprise.com || true
docker exec "$BENIGN"   curl -s -o /dev/null http://enterprise.com || true
docker exec "$ATTACKER" curl -s -o /dev/null http://enterprise.com || true
sleep 3

# 1.4 - Email from enterprise to internet (all available users -> olivia)
echo "--- 1.4 Email enterprise to internet ---"
docker exec "$PC_V50_1" sh -c \
    'echo "Hi Olivia, hope all is well." | mutt -s "Hello from enterprise" olivia@internet.com' || true
docker exec "$PC_V60_1" sh -c \
    'echo "Just wanted to check in from my floor." | mutt -s "Quick hello" olivia@internet.com' || true
docker exec "$PC_ADMIN" sh -c \
    'echo "Sending the weekly reports, please confirm uppon receipt." | mutt -s "Weekly reports" olivia@internet.com' || true
if [ "$HAS_PC_V50_2" = "1" ]; then
    docker exec "$PC_V50_2" sh -c \
        'echo "Sharing the meeting notes from today." | mutt -s "Meeting notes" olivia@internet.com' || true
fi
if [ "$HAS_PC_V60_2" = "1" ]; then
    docker exec "$PC_V60_2" sh -c \
        'echo "Forwarding the schedule for next week." | mutt -s "Updated schedule" olivia@internet.com' || true
fi
sleep 3

# 1.5 - Email from internet to enterprise (olivia -> alice)
echo "--- 1.5 Email internet to enterprise ---"
docker exec "$BENIGN" sh -c \
    'echo "Thanks Alice, received your message. Talk soon." | mutt -s "Re: Hello from enterprise" alice@enterprise.com' || true
sleep 3

# 1.6 - Reply from enterprise (alice -> olivia)
echo "--- 1.6 Reply enterprise -> internet ---"
docker exec "$PC_V50_1" sh -c \
    'echo "Great, looking forward to it!" | mutt -s "Re: Re: Hello from enterprise" olivia@internet.com' || true
sleep 3

# =============================================================================
# PHASE 2 - Normal traffic (mid-session)
# =============================================================================

log "PHASE 2 - Normal traffic (mid-session)"
docker exec "$PC_V50_1" wget -q -O /dev/null http://internet.com || true
docker exec "$PC_V60_1" sh -c \
    'echo "Checking in mid-week, everything looking fine on my end." | mutt -s "Midweek note" olivia@internet.com' || true
docker exec "$BENIGN" curl -s -o /dev/null http://enterprise.com || true
if [ "$HAS_PC_V50_2" = "1" ]; then
    docker exec "$PC_V50_2" curl -s -o /dev/null http://internet.com || true
fi
if [ "$HAS_PC_V60_2" = "1" ]; then
    docker exec "$PC_V60_2" curl -s -o /dev/null http://internet.com || true
fi
sleep 3

# =============================================================================
# PHASE 3 - Final normal traffic
# =============================================================================

log "PHASE 3 - Final normal traffic"
docker exec "$PC_V60_1" curl -s -o /dev/null http://enterprise.com || true
docker exec "$PC_V50_1" nslookup internet.com   || true
docker exec "$PC_ADMIN" nslookup enterprise.com || true
docker exec "$PC_ADMIN" sh -c \
    'echo "End of day, all tasks completed." | mutt -s "EOD summary" olivia@internet.com' || true
if [ "$HAS_PC_V50_2" = "1" ]; then
    docker exec "$PC_V50_2" sh -c \
        'echo "Wrapping up, see you tomorrow." | mutt -s "End of day" olivia@internet.com' || true
fi
if [ "$HAS_PC_V60_2" = "1" ]; then
    docker exec "$PC_V60_2" curl -s -o /dev/null http://enterprise.com || true
fi
sleep 3

# =============================================================================
# DONE - Stats and extraction instructions
# =============================================================================

log "DONE - Benign dataset generation complete"
echo ""
echo "--- To extract the log to the host ---"
echo ""
echo "  docker cp $LOGWATCH:$EVE_LOG ./ml/data/eve_benign_\$(date +%Y%m%d_%H%M%S).json"
echo ""
echo "--- To clear the log before the next run ---"
echo ""
echo "  docker exec $LOGWATCH sh -c '> $EVE_LOG'"
echo ""

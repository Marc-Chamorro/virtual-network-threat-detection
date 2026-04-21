#!/bin/sh

# generate_attacks.sh
# Generates ATTACKS-ONLY traffic for Suricata EVE JSON dataset collection
# Use this to produce malicious traffic samples for AI model training
# Compatible with both topology.clab.yml (full) and topology_reduced.clab.yml (reduced)

# If called with -n, return the menu name (compatible with the attacks menu system)
if [ "$1" = "-n" ]; then
    echo "[-] Dataset generation | Attacks only"
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
# PHASE 1 - Port scanning (nmap SYN + UDP)
# =============================================================================

log "PHASE 1 - Port scanning (nmap)"
sh "$ATTACKS_DIR/port_scanning.sh" "$ATTACKER"
sleep 5

# =============================================================================
# PHASE 2 - DoS SYN flood (hping3, 2 x 60 s phases)
# =============================================================================

log "PHASE 2 - DoS SYN flood (hping3)"
sh "$ATTACKS_DIR/dos_syn_flood_hping3.sh" "$ATTACKER"
sleep 5

# =============================================================================
# PHASE 3 - SSH brute force (hydra)
# =============================================================================

log "PHASE 3 - SSH brute force (hydra)"
sh "$ATTACKS_DIR/ssh_bruteforce_hydra.sh" "$ATTACKER" enterprise.com 22 vntd
sleep 5

# =============================================================================
# PHASE 4 - SMTP recon + IMAP brute force
# =============================================================================

log "PHASE 4 - SMTP recon + IMAP brute force"
# Note: the filename has a space - quoting is required
sh "$ATTACKS_DIR/smtp _recon_abuse.sh" "$ATTACKER" || true
sleep 5

# =============================================================================
# DONE - Stats and extraction instructions
# =============================================================================

log "DONE - Attacks dataset generation complete"
echo ""
echo "--- To extract the log to the host ---"
echo ""
echo "  docker cp $LOGWATCH:$EVE_LOG ./ml/data/eve_attacks_\$(date +%Y%m%d_%H%M%S).json"
echo ""
echo "--- To clear the log before the next run ---"
echo ""
echo "  docker exec $LOGWATCH sh -c '> $EVE_LOG'"
echo ""

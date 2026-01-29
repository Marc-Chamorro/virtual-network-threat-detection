#!/bin/sh

set -e

# Enable IP forwarding to allow traffic routing
sysctl -w net.ipv4.ip_forward=1

# Clear existing rules
iptables -F             # Filter table
iptables -t nat -F      # NAT table
iptables -t mangle -F   # Mangle table
iptables -X             # Delete user-defined chains

# Set default policies, drop all incoming and forwarded traffic, allow all outgoing traffic
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# DHCP Relay -> Allow DHCP requests transfer
if [ "$DHCP_RELAY" == "1" ]; then
    service isc-dhcp-relay start
fi

# Keep the container running
sleep infinity

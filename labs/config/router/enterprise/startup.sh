#!/bin/bash

set -e

# =================================================================================================
# IP configuration
# =================================================================================================

# Public IP address
ip addr add 172.16.30.2/30 dev eth1

# Internal link to the firewall
ip addr add 192.168.0.1/30 dev eth2

# Bring up both physical interfaces
ip link set eth1 up
ip link set eth2 up

# =================================================================================================
# Routing
# =================================================================================================

# Remvoe default route and point to internet router
ip route del default
ip route add default via 172.16.30.1

# Static Routes: Tell the router how to reach internal subnets through the Firewall
ip route add 192.168.10.0/24 via 192.168.0.2
ip route add 192.168.20.0/24 via 192.168.0.2
ip route add 192.168.30.0/24 via 192.168.0.2
ip route add 192.168.40.0/24 via 192.168.0.2
ip route add 192.168.50.0/24 via 192.168.0.2
ip route add 192.168.60.0/24 via 192.168.0.2

# =================================================================================================
# NAT
# =================================================================================================

# Allow internal private IPs to access the internet by hiding behind this router's IP
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# =================================================================================================
# Forward traffic
# =================================================================================================

# Forward incoming HTTP requests to the Firewall (which later forwards to  the DMZ)
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.168.0.2

# =================================================================================================
# OSPF
# =================================================================================================

# Configure the FTT to advertise the network to the internet
cat <<EOF > /etc/frr/frr.conf
frr version 8
frr defaults traditional
hostname router-enterprise
log syslog informational
no ipv6 forwarding

router ospf
 passive-interface default
 no passive-interface eth1
 network 172.16.30.0/30 area 0
EOF

# Start the FRR service
/usr/lib/frr/frrinit.sh start


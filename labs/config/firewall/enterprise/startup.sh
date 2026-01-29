#!/bin/bash

set -e

# =================================================================================================
# Network Interface
# =================================================================================================

# Bring up all physical interfaces
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up
ip link set eth4 up
ip link set eth5 up
ip link set eth6 up
ip link set eth7 up

# Assign Gateway IPs for dedicated zones (thesse act as the default gateway for the devices)
ip addr add 192.168.0.2/30 dev eth1   # Link to Enterprise Router
ip addr add 192.168.10.1/24 dev eth2  # DMZ (VLAN 10)
ip addr add 192.168.20.1/24 dev eth3  # Monitoring (VLAN 20)
ip addr add 192.168.30.1/24 dev eth4  # Admin (VLAN 30)
ip addr add 192.168.40.1/24 dev eth5  # Services (VLAN 40)

# =================================================================================================
# VLAN & bridge configuration
# =================================================================================================

# Because eth6 & ath7 are connected to Trunk ports carrying VLANs 50 and 60, we need to create VLAN
# sub-interfaces and bridge them together so both floors share the same Layer 2 domain.

# Create Bridges
ip link add br-vlan50 type bridge
ip link add br-vlan60 type bridge

# FLOOR 1 and 2 - VLAN 50 and 60
# Create VLAN sub-interfaces, eth6 to Floor 1 Switch, eth7 Floor 2 Switch
ip link add link eth6 name eth6.50 type vlan id 50
ip link add link eth6 name eth6.60 type vlan id 60
ip link add link eth7 name eth7.50 type vlan id 50
ip link add link eth7 name eth7.60 type vlan id 60

# Bring up VLAN interfaces
ip link set eth6.50 up
ip link set eth6.60 up
ip link set eth7.50 up
ip link set eth7.60 up

# Attach VLAN interfaces to their respective bridges
ip link set eth6.50 master br-vlan50
ip link set eth7.50 master br-vlan50
ip link set eth6.60 master br-vlan60
ip link set eth7.60 master br-vlan60

# Assign Gateway IPs to the bridges (thesse act as the default gateway for the devices)
ip addr add 192.168.50.1/24 dev br-vlan50
ip addr add 192.168.60.1/24 dev br-vlan60

# Enable Bridges
ip link set br-vlan50 up
ip link set br-vlan60 up

# Disable STP, otherwirse it believes there are loops on the virtual ports and blocks one of them
brctl stp br-vlan50 off
brctl stp br-vlan60 off

# =================================================================================================
# Routing
# =================================================================================================

# Default route, send unknown traffic to the router
ip route del default
ip route add default via 192.168.0.1

# =================================================================================================
# Security
# =================================================================================================

# Base policies
#--------------------------------------------------------------------------------------------------

# Allow local loopback (recommended)
iptables -A INPUT -i lo -j ACCEPT

# Allow ICMP (Ping) to the firewall, not through it
iptables -A INPUT -p icmp -s 192.168.0.0/16 -j ACCEPT

# VLAN 10 - DMZ
#--------------------------------------------------------------------------------------------------
# Allow HTTP (80) and SSH (22) from anywhere to the DMZ server

# DNAT - From the Internet to the server
iptables -t nat -A PREROUTING -i eth1 -p tcp -m multiport --dports 80,22 -j DNAT --to-destination 192.168.10.10

# Allow connections to the server
iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Allow server responses
iptables -A FORWARD -s 192.168.10.10 -m state --state ESTABLISHED,RELATED -j ACCEPT

# VLAN 20 - Monitoring & IDS
#--------------------------------------------------------------------------------------------------

# Clone all incoming traffic on eth1 (port with access to the outside world) and send a copy to the IDS device
# The IDS must be in promiscuous mode to receive this traffic
iptables -t mangle -A PREROUTING -i eth1 -j TEE --gateway 192.168.20.10

# Prevent the IDS from returning the traffic
iptables -A FORWARD -s 192.168.20.10 -j DROP

# VLAN 30 - Administration
#--------------------------------------------------------------------------------------------------

# Unrestricted access to all other subnets
iptables -A FORWARD -s 192.168.30.0/24 -j ACCEPT

# VLAN 40 - Internal services
#--------------------------------------------------------------------------------------------------

# Services can communicate with Admin and Users Floor networks
iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.50.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.60.0/24 -j ACCEPT

# VLAN 50 & 60 - User floor 1 & 2
#--------------------------------------------------------------------------------------------------
# Users can access the Internet, DMZ and Internal Services, but can not Admin or Monitoring networks

# VLAN 50
iptables -A FORWARD -i br-vlan50 -o eth1 -j ACCEPT
iptables -A FORWARD -i br-vlan50 -d 192.168.10.0/24 -j ACCEPT
iptables -A FORWARD -i br-vlan50 -d 192.168.40.0/24 -j ACCEPT

# VLAN 60 - FLOOR 2
iptables -A FORWARD -i br-vlan60 -o eth1 -j ACCEPT
iptables -A FORWARD -i br-vlan60 -d 192.168.10.0/24 -j ACCEPT
iptables -A FORWARD -i br-vlan60 -d 192.168.40.0/24 -j ACCEPT

# By default, all Forward packets if not specified are dropped (set on the Firewall entrypoint script)
# iptables -P FORWARD DROP

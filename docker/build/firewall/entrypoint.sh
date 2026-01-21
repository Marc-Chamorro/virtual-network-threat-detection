#!/bin/sh

set -e

sysctl -w net.ipv4.ip_forward=1

# Clear existing rules
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

# https://wiki.archlinux.org/title/Simple_stateful_firewall#Setting_up_a_NAT_gateway
# still testing this, not sure if im missing something or not

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback traffic
# iptables -A INPUT -i lo -j ACCEPT

# Allow established and related traffic
# This rule is necessary for stateful firewalls to function correctly,
#if [ "$STATEFULL" = "1" ]; then
    # it allows packets that are part of an existing connection or related to it
#    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    # Allow forwarding of established and related traffic
#    iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#fi

#if [ "$STATELESS" = "1" ]; then
#    iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
#    iptables -A FORWARD -p tcp --dport 443 -j ACCEPT
#fi

sleep infinity

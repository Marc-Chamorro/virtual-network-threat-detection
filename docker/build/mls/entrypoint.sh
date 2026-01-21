#!/bin/bash
set -e

sysctl -w net.ipv4.ip_forward=1

# Netegem regles d'iptables antigues
iptables -F # Clean the filter table
iptables -t nat -F # Clean the NAT table
iptables -t mangle -F # Clean the MANGLE table
iptables -X # Delete all user-defined chains in filter table

sleep infinity

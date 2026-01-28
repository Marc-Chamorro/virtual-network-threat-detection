#!/bin/bash

set -e

# =================================================================================================
# Multilayer switch configuration (Reference Implementation)
# =================================================================================================

# Older configuration where all ports were in turnk mode and each one only carried a single VLAN

# VLAN trunk interfaces
ip link add link eth2 name eth2.10 type vlan id 10
ip link add link eth3 name eth3.20 type vlan id 20
ip link add link eth4 name eth4.30 type vlan id 30
ip link add link eth5 name eth5.40 type vlan id 40
ip link add link eth6 name eth6.50 type vlan id 50
ip link add link eth7 name eth7.60 type vlan id 60

# VLAN IP assignments
ip addr add 192.168.10.1/24 dev eth2.10
ip addr add 192.168.20.1/24 dev eth3.20
ip addr add 192.168.30.1/24 dev eth4.30
ip addr add 192.168.40.1/24 dev eth5.40
ip addr add 192.168.50.1/24 dev eth6.50
ip addr add 192.168.60.1/24 dev eth7.60

# Interfaces up
ip link set dev eth1 up
ip link set dev eth2.10 up
ip link set dev eth3.20 up
ip link set dev eth4.30 up
ip link set dev eth5.40 up
ip link set dev eth6.50 up
ip link set dev eth7.60 up

# IP to go out to Internet
ip addr add 192.168.0.2/30 dev eth1
ip route del default
ip route add default via 192.168.0.1
#!/bin/bash

set -e

ip addr add 192.168.0.6/30 dev eth1
ip addr add 192.168.0.1/30 dev eth2 
ip link set eth1 up
ip link set eth2 up

ip route del default
ip route add 192.168.10.0/24 via 192.168.0.2
ip route add 192.168.20.0/24 via 192.168.0.2
ip route add 192.168.30.0/24 via 192.168.0.2
ip route add 192.168.40.0/24 via 192.168.0.2
ip route add 192.168.50.0/24 via 192.168.0.2
ip route add 192.168.60.0/24 via 192.168.0.2
ip route add default via 192.168.0.5

iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Port forwarding to DMZ server
# PREROUTING - incoming packets
# DNAT - change destination address/port
# --to-destination - new address/port
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.168.10.10:80
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22 -j DNAT --to-destination 192.168.10.10:22

# IDS -> VLAN 20
iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.100.0/24 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Dont even know why these are here
#iptables -A FORWARD -i eth1 -o eth2 -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#iptables -A FORWARD -i eth2 -o eth1 -s 192.168.10.10 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow responses from DMZ to Internet
iptables -A FORWARD -d 192.168.10.10/32 -p tcp -m multiport --dports 80,22 -j ACCEPT
iptables -A FORWARD -s 192.168.10.10/32 -m state --state ESTABLISHED,RELATED -j ACCEPT

/usr/lib/frr/frrinit.sh start
#!/bin/bash

set -e

ip addr add 172.16.30.2/30 dev eth1
ip addr add 192.168.0.1/30 dev eth2
ip link set eth1 up
ip link set eth2 up

ip route del default
ip route add 192.168.10.0/24 via 192.168.0.2
ip route add 192.168.20.0/24 via 192.168.0.2
ip route add 192.168.30.0/24 via 192.168.0.2
ip route add default via 172.16.30.1

iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

/usr/lib/frr/frrinit.sh start
#!/bin/bash

set -e

ip addr add 172.16.30.2/30 dev eth1
ip addr add 192.168.0.5/30 dev eth2
ip addr add 192.168.100.1/24 dev eth3

ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

ip route del default
ip route add default via 172.16.30.1
ip route add 192.168.10.0/24 via 192.168.0.6
ip route add 192.168.20.0/24 via 192.168.0.6
ip route add 192.168.30.0/24 via 192.168.0.6
ip route add 192.168.40.0/24 via 192.168.0.6
ip route add 192.168.50.0/24 via 192.168.0.6
ip route add 192.168.60.0/24 via 192.168.0.6


# NO FILTERING - LATER CHECK IF THIS IS GOOD OR NOT
iptables -P FORWARD ACCEPT
iptables -F FORWARD
#iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
#iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT

iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Duplicate traffic to IDS
# Mirror only traffic NOT destined to the IDS subnet itself (provided by AI, needs to be tested) (okay it works really bad, try to find a workaround)
iptables -t mangle -A PREROUTING ! -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2
# v2
#iptables -t mangle -A PREROUTING ! -s 192.168.100.0/24 -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2
#v3 working on yet # https://superuser.com/questions/1289166/mirror-all-traffic-from-one-port-to-another-on-localhost-using-iptables
# A PROVAR, PERO EN TEORIA JA NO FA BUCLE PERQUE JA HA ENTRAT AL ROUTER, ANTERIORMENT EL DESTI ERA SEMPRE EL MATEIX INCLOS ELS DELS CLONS I PER TANT -> ES TORNAVA A EXECUTAR
# ARA JA ESTA A DINS DEL ROUTER, PER TANT SI EL ORIGEN COM QUE JA NO ES ETH1 (JA ES A DINS) NO S'HAURIA DE DUPLICAR
# A PROVAR
iptables -t mangle -A PREROUTING -i eth1 ! -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2
iptables -t mangle -A PREROUTING -i eth2 ! -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2

#iptables -t mangle -A PREROUTING -j TEE --gateway 192.168.100.2
#iptables -t mangle -A POSTROUTING -j TEE --gateway 192.168.100.2

iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.168.0.6:80
iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22 -j DNAT --to-destination 192.168.0.6:22

iptables -A FORWARD -p tcp -d 192.168.0.6 --dport 80 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.0.6 --dport 22 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


# IDS -> VLAN 20
iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.20.0/24 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 192.168.100.0/24 -j DROP

# Ping allowed
iptables -A INPUT -p icmp -j ACCEPT
iptables -A FORWARD -p icmp -j ACCEPT
#!/bin/bash

set -e

ip link set eth1 up
ip link set eth2 up
ip link set eth3 up
ip link set eth4 up
ip link set eth5 up
ip link set eth6 up
ip link set eth7 up

ip addr add 192.168.0.2/30 dev eth1   # Link to Router
ip addr add 192.168.10.1/24 dev eth2  # DMZ
ip addr add 192.168.20.1/24 dev eth3  # MONITORING
ip addr add 192.168.30.1/24 dev eth4  # ADMIN
ip addr add 192.168.40.1/24 dev eth5  # SERVICES

ip link add br-vlan50 type bridge
ip link add br-vlan60 type bridge

# FLOOR 1 and 2 - VLAN 50 and 60
ip link add link eth6 name eth6.50 type vlan id 50
ip link add link eth6 name eth6.60 type vlan id 60
ip link add link eth7 name eth7.50 type vlan id 50
ip link add link eth7 name eth7.60 type vlan id 60

ip link set eth6.50 up
ip link set eth6.60 up
ip link set eth7.50 up
ip link set eth7.60 up

# Create sub-interfaces and attach them to the bridges
ip link set eth6.50 master br-vlan50
ip link set eth7.50 master br-vlan50
ip link set eth6.60 master br-vlan60
ip link set eth7.60 master br-vlan60

# Assign IP addresses to the bridges
ip addr add 192.168.50.1/24 dev br-vlan50
ip addr add 192.168.60.1/24 dev br-vlan60

ip link set br-vlan50 up
ip link set br-vlan60 up

# STP needs to be disabled, otherwirse it believes there are loops on the virtual ports and blocks one of them
brctl stp br-vlan50 off
brctl stp br-vlan60 off

# Ruta per defecte cap a Internet (via Router)
ip route del default
ip route add default via 192.168.0.1

##################################################################################################

# Permetre tràfic intern del propi Firewall
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Permetre ping al firewall des de qualsevol lloc
iptables -A INPUT -p icmp -s 192.168.0.0/16 -j ACCEPT
#iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT # Permetre gestió des de la xarxa interna

# Allow established and related connections
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# VLAN 10 - DMZ
iptables -A FORWARD -d 192.168.10.10 -p tcp --dport 80 -j ACCEPT
iptables -A FORWARD -d 192.168.10.10 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -j ACCEPT
iptables -t nat -A PREROUTING -i eth1 -p tcp -m multiport --dports 80,22 -j DNAT --to-destination 192.168.10.10

iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.10.10
iptables -t nat -A PREROUTING -p tcp --dport 22 -j DNAT --to-destination 192.168.10.10

# VLAN 20 - MONITORING
iptables -t mangle -A PREROUTING -i eth1 -j TEE --gateway 192.168.20.10
iptables -A FORWARD -s 192.168.20.10 -j DROP

# VLAN 30 - ADMIN
iptables -A FORWARD -s 192.168.30.0/24 -j ACCEPT

# VLAN 40 - SERVICES
iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.50.0/24 -j ACCEPT
iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.60.0/24 -j ACCEPT

# VLAN 50 - FLOOR 1
iptables -A FORWARD -i br-vlan50 -o eth1 -j ACCEPT
iptables -A FORWARD -i br-vlan50 -d 192.168.10.0/24 -j ACCEPT
iptables -A FORWARD -i br-vlan50 -d 192.168.40.0/24 -j ACCEPT

# VLAN 60 - FLOOR 2
iptables -A FORWARD -i br-vlan60 -o eth1 -j ACCEPT
iptables -A FORWARD -i br-vlan60 -d 192.168.10.0/24 -j ACCEPT
iptables -A FORWARD -i br-vlan60 -d 192.168.40.0/24 -j ACCEPT













# Internal IP to the Router
#ip addr add 192.168.0.2/30 dev eth1
#ip link set eth1 up

# DMZ - VLAN 10
#ip addr add 192.168.10.1/24 dev eth2
#ip link set eth2 up

# MONITORING - VLAN 20
#ip addr add 192.168.20.1/24 dev eth3
#ip link set eth3 up

# ADMIN - VLAN 30
#ip addr add 192.168.30.1/24 dev eth4
#ip link set eth4 up

# SERVICES - VLAN 40
#ip addr add 192.168.40.1/24 dev eth5
#ip link set eth5 up

#ip link set eth6 up
#ip link set eth7 up

# Create bridges for VLANs 50 and 60
#ip link add br-vlan50 type bridge
#ip link add br-vlan60 type bridge

# FLOOR 1 and 2 - VLAN 50 and 60
#ip link add link eth6 name eth6.50 type vlan id 50
#ip link add link eth6 name eth6.60 type vlan id 60
#ip link add link eth7 name eth7.50 type vlan id 50
#ip link add link eth7 name eth7.60 type vlan id 60

#ip link set eth6.50 up
#ip link set eth6.60 up
#ip link set eth7.50 up
#ip link set eth7.60 up

# Create sub-interfaces and attach them to the bridges
#ip link set eth6.50 master br-vlan50
#ip link set eth7.50 master br-vlan50
#ip link set eth6.60 master br-vlan60
#ip link set eth7.60 master br-vlan60

# Assign IP addresses to the bridges
#ip addr add 192.168.50.1/24 dev br-vlan50
#ip addr add 192.168.60.1/24 dev br-vlan60
#ip link set br-vlan50 up
#ip link set br-vlan60 up



# FLOOR 1 - VLAN 50 and 60
#ip link add link eth6 name eth6.50 type vlan id 50
#ip link add link eth6 name eth6.60 type vlan id 60
#ip addr add 192.168.50.1/24 dev eth6.50
#ip addr add 192.168.60.1/24 dev eth6.60
#ip link set eth6 up
#ip link set eth6.50 up
#ip link set eth6.60 up

# FLOOR 2 - VLAN 50 and 60
#ip link add link eth7 name eth7.50 type vlan id 50
#ip link add link eth7 name eth7.60 type vlan id 60
#ip link set eth7 up
#ip link set eth7.50 up
#ip link set eth7.60 up

# Default route to Internet through the Router
#ip route del default
#ip route add default via 192.168.0.1

##################################################################################################
# Rules
##################################################################################################

# Evitar que iptables bloquegi tràfic intern dels bridges
#sysctl -w net.bridge.bridge-nf-call-iptables=0
#sysctl -w net.bridge.bridge-nf-call-arptables=0
#sysctl -w net.bridge.bridge-nf-call-ip6tables=0

# Disable IP forwarding first
#iptables -P FORWARD DROP

# Permetre que el propi Firewall respongui als pings (INPUT)
#iptables -A INPUT -p icmp -j ACCEPT
#iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permetre que les xarxes locals parlin amb el Firewall (DNS, DHCP, Gateway, etc.)
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT

# Allow returning traffic for established connections
#iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# VLAN 10
# iptables -A FORWARD -i eth1 -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -j ACCEPT
#iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -j ACCEPT

# VLAN 20
#iptables -t mangle -A PREROUTING -i eth1 ! -d 192.168.20.0/24 -j TEE --gateway 192.168.20.10

# VLAN 30
#iptables -A FORWARD -s 192.168.30.0/24 -j ACCEPT

# VLAN 40
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.60.0/24 -j ACCEPT

# VLAN 50
#iptables -A FORWARD -i br-vlan50 -o eth1 -j ACCEPT
#iptables -A FORWARD -i br-vlan50 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -i br-vlan50 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -i br-vlan50 -d 192.168.50.0/24 -j ACCEPT

# VLAN 60
#iptables -A FORWARD -i br-vlan60 -o eth1 -j ACCEPT
#iptables -A FORWARD -i br-vlan60 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -i br-vlan60 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -i br-vlan60 -d 192.168.60.0/24 -j ACCEPT

# NAT
# Redirect HTTP and SSH traffic to the DMZ server
#iptables -t nat -A PREROUTING -i eth1 -p tcp -m multiport --dports 80,22 -j DNAT --to-destination 192.168.10.10
# Allow forwarding of the redirected traffic to the DMZ server
#iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -j ACCEPT
# Assign source IP for traffic going out to the Internet????(dont know if this comment is good or not)
#iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE


































# Rule for loopback
#iptables -A INPUT -i lo -j ACCEPT
# Allow established and related connections
#iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Allow ping
#iptables -A INPUT -p icmp -j ACCEPT

# Allow established and related connections
#iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# NAT
# iptables -t nat -A POSTROUTING -o eth1 -s 192.168.0.0/16 -j MASQUERADE

# DNAT
#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to 192.168.10.10
#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22 -j DNAT --to 192.168.10.10
#iptables -t nat -A PREROUTING -i eth1 -p tcp -m multiport --dports 80,22 -j DNAT --to 192.168.10.10
#iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -m conntrack --ctstate NEW -j ACCEPT
#iptables -t nat -A POSTROUTING -s 192.168.10.10 -o eth1 -j SNAT --to-source 192.168.0.2
#iptables -A FORWARD -s 192.168.10.0/24 -m conntrack --ctstate NEW -j DROP


#iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -j ACCEPT

# DMZ
#iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
#iptables -A FORWARD -s 192.168.10.0/24 -j DROP

# IDS
#iptables -A FORWARD -d 192.168.20.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -s 192.168.20.0/24 -j DROP
#iptables -A FORWARD -d 192.168.20.0/24 -j ACCEPT
#iptables -t mangle -A PREROUTING -i eth1 -j TEE --gateway 192.168.20.10
#iptables -t mangle -A PREROUTING -i eth1 ! -d 192.168.20.0/24 -j TEE --gateway 192.168.20.10

# Admin
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.60.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -j ACCEPT

# Services
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.60.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -j DROP

# Floor 1
#iptables -A FORWARD -s 192.168.50.0/24 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -d 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -j DROP

# Floor 2
#iptables -A FORWARD -s 192.168.60.0/24 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -d 192.168.60.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -j DROP





















# Stateful
#iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# DMZ 
#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to 192.168.10.10
#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22 -j DNAT --to 192.168.10.10
#iptables -A FORWARD -d 192.168.10.10 -p tcp -m multiport --dports 80,22 -j ACCEPT

# VLAN20 - IDS
#iptables -A FORWARD -s 192.168.20.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.20.0/24 -j DROP

#iptables -A FORWARD -s 192.168.20.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.10.0/24 -j ACCEPT
    # IDS -> VLAN 20
#iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.20.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.20.0/24 -d 192.168.100.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.20.0/24 -j DROP
#iptables -A FORWARD -s 192.168.20.0/24 -j ACCEPT
#iptables -A FORWARD -d 192.168.20.0/24 -j ACCEPT

# VLAN30 - Admin
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.20.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -d 192.168.60.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.30.0/24 -o eth1 -j ACCEPT

#iptables -A FORWARD -d 192.168.30.0/24 -j DROP

# VLAN40 - Servers
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.30.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.40.0/24 -d 192.168.60.0/24 -j ACCEPT

#iptables -A FORWARD -d 192.168.40.0/24 -s 192.168.30.0/24 -j ACCEPT
#iptables -A FORWARD -d 192.168.40.0/24 -s 192.168.50.0/24 -j ACCEPT
#iptables -A FORWARD -d 192.168.40.0/24 -s 192.168.60.0/24 -j ACCEPT

#iptables -A FORWARD -s 192.168.40.0/24 -j DROP

# VLAN50 - Users A
#iptables -A FORWARD -s 192.168.50.0/24 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.50.0/24 -j DROP

# VLAN60 - Users B
#iptables -A FORWARD -s 192.168.60.0/24 -d 192.168.10.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -d 192.168.40.0/24 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -o eth1 -j ACCEPT
#iptables -A FORWARD -s 192.168.60.0/24 -j DROP

# Redirect traffic to IDS
#iptables -t mangle -A PREROUTING -i eth1 -j TEE --gateway 192.168.20.10

# Default DROP
#iptables -A FORWARD -j DROP

#ip addr add 172.16.30.2/30 dev eth1
#ip addr add 192.168.0.5/30 dev eth2
#ip addr add 192.168.100.1/24 dev eth3

#ip link set eth1 up
#ip link set eth2 up
#ip link set eth3 up

#ip route del default
#ip route add default via 172.16.30.1
#ip route add 192.168.10.0/24 via 192.168.0.6
#ip route add 192.168.20.0/24 via 192.168.0.6
#ip route add 192.168.30.0/24 via 192.168.0.6
#ip route add 192.168.40.0/24 via 192.168.0.6
#ip route add 192.168.50.0/24 via 192.168.0.6
#ip route add 192.168.60.0/24 via 192.168.0.6


# NO FILTERING - LATER CHECK IF THIS IS GOOD OR NOT
#iptables -P FORWARD ACCEPT
#iptables -F FORWARD
#iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
#iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT

#iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# Duplicate traffic to IDS
# Mirror only traffic NOT destined to the IDS subnet itself (provided by AI, needs to be tested) (okay it works really bad, try to find a workaround)
#iptables -t mangle -A PREROUTING ! -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2
# v2
#iptables -t mangle -A PREROUTING ! -s 192.168.100.0/24 -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2
#v3 working on yet # https://superuser.com/questions/1289166/mirror-all-traffic-from-one-port-to-another-on-localhost-using-iptables
# A PROVAR, PERO EN TEORIA JA NO FA BUCLE PERQUE JA HA ENTRAT AL ROUTER, ANTERIORMENT EL DESTI ERA SEMPRE EL MATEIX INCLOS ELS DELS CLONS I PER TANT -> ES TORNAVA A EXECUTAR
# ARA JA ESTA A DINS DEL ROUTER, PER TANT SI EL ORIGEN COM QUE JA NO ES ETH1 (JA ES A DINS) NO S'HAURIA DE DUPLICAR
# A PROVAR
#iptables -t mangle -A PREROUTING -i eth1 ! -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2
#iptables -t mangle -A PREROUTING -i eth2 ! -d 192.168.100.0/24 -j TEE --gateway 192.168.100.2

#iptables -t mangle -A PREROUTING -j TEE --gateway 192.168.100.2
#iptables -t mangle -A POSTROUTING -j TEE --gateway 192.168.100.2

#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.168.0.6:80
#iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22 -j DNAT --to-destination 192.168.0.6:22

#iptables -A FORWARD -p tcp -d 192.168.0.6 --dport 80 -j ACCEPT
#iptables -A FORWARD -p tcp -d 192.168.0.6 --dport 22 -j ACCEPT
#iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


# IDS -> VLAN 20
#iptables -A FORWARD -s 192.168.100.0/24 -d 192.168.20.0/24 -j ACCEPT
#iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#iptables -A FORWARD -s 192.168.100.0/24 -j DROP

# Ping allowed
#iptables -A INPUT -p icmp -j ACCEPT
#iptables -A FORWARD -p icmp -j ACCEPT
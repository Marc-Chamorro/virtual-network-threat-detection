#!/bin/bash

set -e

IFACE="${IFACE:-eth1}"  
RETRY_DELAY=5

while ! ip link show "${IFACE}" >/dev/null 2>&1; do
    sleep "$RETRY_DELAY"
done

ip addr add "$IP_ADDR" dev "$IFACE"
ip link set "$IFACE" up
ip route del default
ip route add default via "$IP_GTWY"
ip link set "$IFACE" promisc on 
#- sysctl -w net.ipv4.ip_forward=0
#- iptables -P FORWARD DROP                 # IDS should not forward any traffic, only analyze

# IDS
if [ "$IDS_SURICATA" == "1" ]; then

    echo "Starting Suricata on $IFACE..."
    exec suricata -c /etc/suricata/suricata.yaml -i "$IFACE"

fi

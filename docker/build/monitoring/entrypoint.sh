#!/bin/bash

set -e

IFACE="${IFACE:-eth1}"  
RETRY_DELAY=5

# Wait for the interface to be up
while ! ip link show "${IFACE}" >/dev/null 2>&1; do
    sleep "$RETRY_DELAY"
done

# Configure the interface
ip addr add "$IP_ADDR" dev "$IFACE"
ip link set "$IFACE" up
#ip route del default
#ip route add default via "$IP_GTWY"
ip route add "$IP_GTWY" dev "$IFACE"
ip link set "$IFACE" promisc on

## In the furute, check the CPU and RAM consumption, so its not taht much

if [ "$ELASTIC" == "1" ]; then
    #elasticsearch -e &

    # https://www.elastic.co/docs/deploy-manage/deploy/self-managed/vm-max-map-count
    # https://opster.com/guides/elasticsearch/capacity-planning/elasticsearch-vm-max-map-count/#:~:text=The%20default%20value%20of%20vm,areas%2C%20especially%20in%20larger%20clusters.
    sudo sysctl -w vm.max_map_count=262144

    # To keep it simple
    if /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep -q xpack.security.transport.ssl.keystore.secure_password; then
        /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password
    fi

    if /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep -q xpack.security.transport.ssl.truststore.secure_password; then
        /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.truststore.secure_password
    fi

    if /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep -q xpack.security.http.ssl.keystore.secure_password; then
        /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.http.ssl.keystore.secure_password
    fi

    # run as the elasticsearch user
    su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch" &
    #su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch -E network.host=192.168.20.11 -E http.host=192.168.20.11" &





    #mkdir -p /var/lib/elasticsearch
    #mkdir -p /var/log/elasticsearch
    #chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
    #chown -R elasticsearch:elasticsearch /var/log/elasticsearch
    #su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch" &
    
    until curl -s http://127.0.0.1:9200 >/dev/null; do
        sleep 5
    done
    #until curl -s http://localhost:9200 >/dev/null; do
    #    sleep 5
    #done

    #kibana -e &

    # run as the kibana user
    #su -s /bin/bash kibana -c "/usr/share/kibana/bin/kibana" &
    #su -s /bin/bash kibana -c "/usr/share/kibana/bin/kibana" &

fi


sleep infinity

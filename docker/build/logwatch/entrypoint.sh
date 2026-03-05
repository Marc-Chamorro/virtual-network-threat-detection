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
#- sysctl -w net.ipv4.ip_forward=0
#- iptables -P FORWARD DROP                 # IDS should not forward any traffic, only analyze

PIDS=()

# Suricata
if [ "$SURICATA_SERVICE" == "1" ]; then

    echo "Starting Suricata on $IFACE..."
    # -D to run on the background - LATER CHECK IF THE -i IS NECESSARY
    suricata -c /etc/suricata/suricata.yaml -i "$IFACE" &
    #suricata -c /etc/suricata/suricata.yaml &
    PIDS+=($!)
    echo "Suricata started with PID $!"
    # Wait a moment to make sure suricata has enough time to start
    sleep "$RETRY_DELAY"

fi

# Elasticsearch
if [ "$SURICATA_SERVICE" == "1" ]; then

    echo "Starting Elasticsearch..."
    sysctl -w vm.max_map_count=262144

    # To keep it simple
    #if /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep -q xpack.security.transport.ssl.keystore.secure_password; then
    #    /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password
    #fi

    #if /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep -q xpack.security.transport.ssl.truststore.secure_password; then
    #    /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.truststore.secure_password
    #fi

    #if /usr/share/elasticsearch/bin/elasticsearch-keystore list | grep -q xpack.security.http.ssl.keystore.secure_password; then
    #    /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.http.ssl.keystore.secure_password
    #fi

    # run as the elasticsearch user
    #su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch" &
    #su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch -e -c /etc/elasticsearch/elasticsearch.yml" &    PIDS+=($!)
    su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch" &
    echo "Elasticsearch started with PID $!"

    # Wait for Elasticsearch to be ready
    while ! curl -s http://localhost:9200 >/dev/null 2>&1; do
        sleep "$RETRY_DELAY"
        echo "Waiting for Elasticsearch to be ready..."
    done
    echo "Elasticsearch ready"

fi

# Kibana
if [ "$SURICATA_SERVICE" == "1" ]; then
    echo "Starting Kibana..."
    #su -s /bin/bash kibana -c "kibana -e -c /etc/kibana/kibana.yml" &
    #su -s /bin/bash kibana -c "/usr/share/kibana/bin/kibana -e -c /etc/kibana/kibana.yml" &
    su -s /bin/bash kibana -c "/usr/share/kibana/bin/kibana" &
    PIDS+=($!)
    echo "Kibana started with PID $!"

    # Wait for Kibana to be ready
    while ! curl -s http://localhost:5601 >/dev/null 2>&1; do
        sleep "$RETRY_DELAY"
        echo "Waiting for Kibana to be ready..."
    done
    echo "Kibana ready"
fi

# Filebeat
if [ "$SURICATA_SERVICE" == "1" ]; then

    # Fix permissions
    echo "Setting Filebeat permissions..."
    chown root:root /etc/filebeat/filebeat.yml
    chmod 600 /etc/filebeat/filebeat.yml
    if [ -f /etc/filebeat/modules.d/suricata.yml ]; then
        chown root:root /etc/filebeat/modules.d/suricata.yml
        chmod 644 /etc/filebeat/modules.d/suricata.yml
    fi

    echo "Enabling Filebeat modules..."
    # Enable Suricata module if not already enabled
    if ! filebeat modules list | grep -q "^suricata.*enabled"; then
        filebeat modules enable suricata
        echo "Suricata module enabled"
    fi

    echo "Starting Filebeat..."
    filebeat -e -c /etc/filebeat/filebeat.yml &
    PIDS+=($!)
    echo "Filebeat started with PID $!"

fi

# Only execute sleep if no background process is being executed
if [ ${#PIDS[@]} -gt 0 ]; then
    wait "${PIDS[@]}"
else
    sleep infinity
fi
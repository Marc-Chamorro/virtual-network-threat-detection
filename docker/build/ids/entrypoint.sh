#!/bin/bash

set -e

IFACE="${IFACE:-eth1}"  
RETRY_DELAY=5

# Wait for the interface to be up
while ! ip link show "${IFACE}" >/dev/null 2>&1; do
    echo "Waiting for interface ${IFACE}..."
    sleep "$RETRY_DELAY"
done

echo "Interface ${IFACE} is up, configuring..."

# Configure the interface
ip addr add "$IP_ADDR" dev "$IFACE"
ip link set "$IFACE" up
ip route del default 2>/dev/null || true
ip route add default via "$IP_GTWY"
ip link set "$IFACE" promisc on

PIDS=()

# IDS
if [ "$IDS_SURICATA" == "1" ]; then
    echo "Starting Suricata on $IFACE..."
    suricata -c /etc/suricata/suricata.yaml -i "$IFACE" &
    PIDS+=($!)
    echo "Suricata started with PID $!"
    sleep 2
fi

# File Transfer - Filebeat
if [ "$FT_FILEBEAT" == "1" ]; then
    echo "Waiting for Elasticsearch to be ready..."
    
    ELASTICSEARCH_URL="http://192.168.20.11:9200"
    MAX_RETRIES=30
    RETRY_COUNT=0
    
    until curl -s "$ELASTICSEARCH_URL/_cluster/health" | grep -q '"status":"green"\|"status":"yellow"'; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
            echo "ERROR: Elasticsearch not available after $MAX_RETRIES attempts"
            exit 1
        fi
        echo "Waiting for Elasticsearch... (attempt $RETRY_COUNT/$MAX_RETRIES)"
        sleep "$RETRY_DELAY"
    done
    
    echo "Elasticsearch is ready"
    
    # Test connection explicitly
    echo "Testing connection to Elasticsearch..."
    if curl -s -f "$ELASTICSEARCH_URL" > /dev/null; then
        echo "Successfully connected to Elasticsearch"
    else
        echo "WARNING: Could not connect to Elasticsearch"
    fi

    # Fix permissions
    echo "Setting Filebeat permissions..."
    chown root:root /etc/filebeat/filebeat.yml
    chmod 600 /etc/filebeat/filebeat.yml
    if [ -f /etc/filebeat/modules.d/suricata.yml ]; then
        chown root:root /etc/filebeat/modules.d/suricata.yml
        chmod 644 /etc/filebeat/modules.d/suricata.yml
    fi

    # Test Filebeat configuration
    echo "Testing Filebeat configuration..."
    if ! filebeat test config -e; then
        echo "ERROR: Filebeat configuration test failed"
        exit 1
    fi

    # Test output connectivity
    echo "Testing Elasticsearch output..."
    if ! filebeat test output; then
        echo "ERROR: Cannot connect to Elasticsearch output"
        # Continue anyway, maybe it's a temporary issue
    fi

    # SKIP the setup step that's failing - let Filebeat auto-create templates
    echo "Skipping Filebeat setup - will auto-create templates when data is sent"
    # THIS ONE ACTUALLY WORKED ON FILEBEAT, MAKES ELASTIC CRASH? BUT FILEBEAT WORKS FINE!
    #filebeat setup --pipelines --modules suricata
    ##filebeat setup --index-management -E output.elasticsearch.hosts=["http://192.168.20.11:9200"]

    # TEST THIS HYBRID:
    #filebeat setup \
    #--index-management \
    #--pipelines \
    #--modules suricata \
    #-E setup.dashboards.enabled=false \
    #-E output.elasticsearch.hosts=["http://192.168.20.11:9200"] \
    #|| echo "Filebeat setup failed, continuing..."

    #filebeat setup --index-management --pipelines \
    #-E setup.dashboards.enabled=false \
    #-E output.elasticsearch.hosts=["http://192.168.20.11:9200"]

    #filebeat setup --pipelines --modules suricata

    until curl -s http://192.168.20.11:9200/_cluster/health?wait_for_status=yellow\&timeout=60s | grep -q '"timed_out":false'; do
        echo "Waiting for full ES readiness..."
        sleep 5
    done

    #filebeat setup \
    #--pipelines \
    #--modules suricata \
    #-E setup.dashboards.enabled=false \
    #-E output.elasticsearch.hosts=["http://192.168.20.11:9200"]

    echo "---- MODULE FILE ----"
    cat /etc/filebeat/modules.d/suricata.yml
    echo "---------------------"

    #filebeat setup \
    #--index-management \
    #--pipelines
    #-E output.elasticsearch.hosts=["http://192.168.20.11:9200"]
    # NO
    #filebeat setup
    filebeat setup --index-management -e

    # Start Filebeat
    echo "Starting Filebeat..."
    rm -rf /var/lib/filebeat/*
    filebeat -e -c /etc/filebeat/filebeat.yml &
    PIDS+=($!)
    echo "Filebeat started with PID $!"
fi

# Wait for background processes
if [ ${#PIDS[@]} -gt 0 ]; then
    echo "Waiting for processes: ${PIDS[@]}"
    wait "${PIDS[@]}"
else
    echo "No background processes, sleeping forever"
    sleep infinity
fi
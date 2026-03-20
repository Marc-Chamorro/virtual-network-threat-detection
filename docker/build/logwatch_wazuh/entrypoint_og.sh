#!/bin/bash

set -e

# Defaults
IFACE="${IFACE:-eth1}"  
RETRY_DELAY=5

# Wazuh endpoints
WAZUH_INDEXER_HOST="http://localhost:9200"
WAZUH_DASHBOARD_HOST="http://localhost:5601"
WAZUH_ADMIN_USER="admin"
WAZUH_ADMIN_PASSWORD="pswd_vntd"

# Store services IDs
PIDS=()

# =================================================================================================
# Network Initialization
# =================================================================================================
while ! ip link show "${IFACE}" >/dev/null 2>&1; do
    sleep "$RETRY_DELAY"
done

ip addr add "$IP_ADDR" dev "$IFACE"
ip link set "$IFACE" up
ip route add "$IP_GTWY" dev "$IFACE"
ip link set "$IFACE" promisc on

# =================================================================================================
# Suricata
# =================================================================================================
if [ "$SURICATA_SERVICE" == "1" ]; then
    echo "Starting Suricata on $IFACE (capture only mode)..."
    suricata -c /etc/suricata/suricata.yaml -i "$IFACE" &
    PIDS+=($!)
    echo "Suricata started with PID $!"
    sleep "$RETRY_DELAY"
fi

# =================================================================================================
# Wazuh Stack
# =================================================================================================
if [ "$WAZUH_STACK" == "1" ]; then

    # ---------------------------------------------------------------------------------------------
    # Wazuh Indexer (OpenSearch) - Security disabled
    # ---------------------------------------------------------------------------------------------
    echo "Starting Wazuh Indexer..."
    sysctl -w vm.max_map_count=262144
    
    # Create default config file
    cat > /etc/default/wazuh-indexer << 'EOF'
# Wazuh indexer configuration
DAEMON_USER=wazuh-indexer
DAEMON_GROUP=wazuh-indexer
EOF
    chown wazuh-indexer:wazuh-indexer /etc/default/wazuh-indexer
    chmod 644 /etc/default/wazuh-indexer

    # Set permissions
    chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer /var/lib/wazuh-indexer /var/log/wazuh-indexer 2>/dev/null || true
    chmod 755 /etc/wazuh-indexer
    chmod 644 /etc/wazuh-indexer/opensearch.yml 2>/dev/null || true

    # Start Indexer
    su -s /bin/bash wazuh-indexer -c "OPENSEARCH_PATH_CONF=/etc/wazuh-indexer /usr/share/wazuh-indexer/bin/opensearch" &
    PIDS+=($!)
    echo "Wazuh Indexer started with PID $!"

    # Wait for Indexer to be ready
    echo "Waiting for Wazuh Indexer to be ready..."
    for i in {1..60}; do
        if curl -s "http://localhost:9200" >/dev/null 2>&1; then
            echo "Wazuh Indexer ready"
            break
        fi
        echo "Attempt $i/60: Indexer not ready yet..."
        sleep "$RETRY_DELAY"
    done

    # ---------------------------------------------------------------------------------------------
    # Wazuh Manager
    # ---------------------------------------------------------------------------------------------
    echo "Starting Wazuh Manager..."
    
    #echo "$WAZUH_ADMIN_PASSWORD" | /var/ossec/bin/wazuh-keystore -f indexer -k password
    #echo "$WAZUH_ADMIN_USER" | /var/ossec/bin/wazuh-keystore -f indexer -k username
    
    /var/ossec/bin/wazuh-control start
    sleep 10
    echo "Wazuh Manager started"

    # Configure Wazuh to read Suricata logs
    if [ "$SURICATA_SERVICE" == "1" ]; then
        echo "Configuring Wazuh to read Suricata logs..."
        chmod 644 /var/log/suricata/eve.json
    fi

    # ---------------------------------------------------------------------------------------------
    # Prepare Dashboard Data Directory
    # ---------------------------------------------------------------------------------------------
    echo "Preparing Dashboard data directory..."
    mkdir -p /usr/share/wazuh-dashboard/data/wazuh/config
    mkdir -p /usr/share/wazuh-dashboard/data/wazuh/logs
    chown -R wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data 2>/dev/null || true
    
    # Ensure config file exists
    if [ ! -f /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml ]; then
        cat > /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml << 'EOF'
# Wazuh Dashboard configuration
hosts:
  - http://localhost:55000
EOF
        chown wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml
    fi

    # ---------------------------------------------------------------------------------------------
    # Wazuh Dashboard
    # ---------------------------------------------------------------------------------------------
    echo "Starting Wazuh Dashboard..."
    
    # Start Dashboard
    su -s /bin/bash wazuh-dashboard -c "/usr/share/wazuh-dashboard/bin/opensearch-dashboards" &
    DASHBOARD_PID=$!
    PIDS+=($DASHBOARD_PID)
    echo "Wazuh Dashboard started with PID $DASHBOARD_PID"

    # Wait for Dashboard to be ready
    echo "Waiting for Wazuh Dashboard to become available..."
    for i in {1..60}; do
        if curl -s "http://localhost:5601/api/status" >/dev/null 2>&1; then
            echo "Wazuh Dashboard ready"
            # Give the plugin a moment to initialize
            sleep 5
            break
        fi
        echo "Attempt $i/60: Dashboard not ready yet..."
        sleep "$RETRY_DELAY"
    done

    # ---------------------------------------------------------------------------------------------
    # Filebeat - Wazuh version
    # ---------------------------------------------------------------------------------------------
    echo "Setting Filebeat permissions..."
    chown root:root /etc/filebeat/filebeat.yml
    chmod 644 /etc/filebeat/filebeat.yml
    
    echo "Starting Filebeat..."
    
    # Create Filebeat keystore and add credentials
    filebeat keystore create 2>/dev/null || true
    echo "$WAZUH_ADMIN_USER" | filebeat keystore add username --stdin --force 2>/dev/null
    echo "$WAZUH_ADMIN_PASSWORD" | filebeat keystore add password --stdin --force 2>/dev/null
    
    # Run Filebeat setup for Wazuh
    #echo "Running Filebeat setup for Wazuh..."
    #filebeat setup \
    #    -E setup.template.json.enabled=true \
    #    -E setup.template.json.path=/etc/filebeat/wazuh-template.json \
    #    -E setup.template.json.name=wazuh \
    #    -E setup.ilm.enabled=false \
    #    -E output.elasticsearch.hosts=["http://localhost:9200"] \
    #    -E output.elasticsearch.username=admin \
    #    -E output.elasticsearch.password=pswd_vntd
    
    # Start Filebeat
    filebeat -e -c /etc/filebeat/filebeat.yml &
    PIDS+=($!)
    echo "Filebeat started with PID $!"
    
    sleep 5

    # ---------------------------------------------------------------------------------------------
    # Final verification
    # ---------------------------------------------------------------------------------------------
    echo ""
    echo "=================================================="
    echo "    WAZUH SIEM READY (NO SSL)"
    echo "=================================================="
    echo ""
    echo "Access Dashboard: http://172.20.20.4:5601"
    echo "User: admin"
    echo "Password: $WAZUH_ADMIN_PASSWORD"
    echo "=================================================="

fi

# =================================================================================================
# Process supervision
# =================================================================================================
if [ ${#PIDS[@]} -gt 0 ]; then
    wait "${PIDS[@]}"
else
    sleep infinity
fi
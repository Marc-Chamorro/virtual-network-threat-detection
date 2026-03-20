#!/bin/bash

set -e

# Defaults to eth1 but can be overridden through the topology file
IFACE="${IFACE:-eth1}"  

# Delay used between retry operations
RETRY_DELAY=5

# Local endpoints for Elastic services
ELASTIC_HOST="http://localhost:9200"
KIBANA_HOST="http://localhost:5601"

# Default Elastic superuser
ELASTIC_USER="elastic"
ELASTIC_PASSWORD=""             # Generated later

# Admin user created for Kibana login
ADMIN_LOGIN="admin"
ADMIN_LOGIN_PASSWORD="12345aA"

# Credentials used internally by Elastic services
KIBANA_PASSWORD="pswd_vntd"

# Filebeat internal authentication configuration
FILEBEAT_ROLE="filebeat_writer"
FILEBEAT_USER="filebeat_internal"
FILEBEAT_PASSWORD="pswd_vntd"

# =================================================================================================
# Network Initialization
# =================================================================================================

# Wait for the interface to be up
while ! ip link show "${IFACE}" >/dev/null 2>&1; do
    sleep "$RETRY_DELAY"
done

# Network Configuration
ip addr add "$IP_ADDR" dev "$IFACE"
ip link set "$IFACE" up
ip route add "$IP_GTWY" dev "$IFACE"
ip link set "$IFACE" promisc on

# The default route is intentionally kept so the container is reachable from the host environment.
# Necessary for using Kibana from the host machine.
#ip route del default
#ip route add default via "$IP_GTWY"

# No need to disable it, the firewall already blocks all outgoing traffic
#sysctl -w net.ipv4.ip_forward=0
#iptables -P FORWARD DROP

# Store services IDs
PIDS=()

# =================================================================================================
# Suricata
# =================================================================================================

if [ "$SURICATA_SERVICE" == "1" ]; then

    echo "Starting Suricata on $IFACE..."

    # -D to run on the background
    # -i to force on the specified interface
    suricata -c /etc/suricata/suricata.yaml -i "$IFACE" &

    PIDS+=($!)
    echo "Suricata started with PID $!"

    # Wait a moment to make sure suricata has enough time to start
    sleep "$RETRY_DELAY"

fi

# =================================================================================================
# Elasticsearch
# =================================================================================================

if [ "$ELASTIC_STACK" == "1" ]; then

    # Starting the service
    #--------------------------------------------------------------------------------------------------

    echo "Starting Elasticsearch..."

    # Required for memory mapping
    sysctl -w vm.max_map_count=262144

    # Start Elasticsearch as the provided elasticsearch user
    su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch" &

    PIDS+=($!)
    echo "Elasticsearch started with PID $!"

    # Wait for Elasticsearch to be ready
    while ! curl -s "$ELASTIC_HOST" >/dev/null 2>&1; do
        sleep "$RETRY_DELAY"
        echo "Waiting for Elasticsearch to be ready..."
    done

    echo "Elasticsearch ready"

    # Passwords, roles and users
    #--------------------------------------------------------------------------------------------------

    # Reset elastic password (non-interactive)
    RESET_OUTPUT=$(/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b)

    # Trim from the provided response (multi-line) the newly generated password
    ELASTIC_PASSWORD=$(echo "$RESET_OUTPUT" | grep "New value" | awk '{print $3}')

    echo "Elastic password: $ELASTIC_PASSWORD"

    # Wait for elasticsearch security system to be up before creating the users / roles
    while ! curl -s -u $ELASTIC_USER:$ELASTIC_PASSWORD "$ELASTIC_HOST"/_security/_authenticate >/dev/null; do
        echo "Waiting for Elasticsearch security..."
        sleep $RETRY_DELAY
    done

    echo "Elasticsearch security ready"

    echo "Configuring passwords..."

    # Set kibana_system password (already provided by elasticsearch)
    curl -s -X POST -u $ELASTIC_USER:$ELASTIC_PASSWORD "$ELASTIC_HOST"/_security/user/kibana_system/_password \
    -H "Content-Type: application/json" \
    -d "{\"password\":\"$KIBANA_PASSWORD\"}"

    # Create a new role for the filebeat system so it can send data
    curl -u $ELASTIC_USER:$ELASTIC_PASSWORD -X POST "$ELASTIC_HOST"/_security/role/"$FILEBEAT_ROLE" \
    -H "Content-Type: application/json" \
    -d '{
        "cluster": ["monitor", "read_ilm", "read_pipeline", "manage_ilm", "manage", "all"],
        "indices": [
            {
            "names": [ "filebeat-*", "logs-*" ],
            "privileges": ["auto_configure", "create_doc", "write", "create", "create_index", "manage"]
            }
        ]
    }'

    # Create a new user with the previously created role 
    curl -u $ELASTIC_USER:$ELASTIC_PASSWORD -X POST "$ELASTIC_HOST"/_security/user/"$FILEBEAT_USER" \
    -H "Content-Type: application/json" \
    -d "{
        \"password\": \"$FILEBEAT_PASSWORD\",
        \"roles\": [\"$FILEBEAT_ROLE\"],
        \"full_name\": \"Filebeat internal user\"
    }"

    echo "Passwords configured"

    # New user to connect to the kibana web service
    echo "Create new user to connect to the web"

    curl -X POST -u $ELASTIC_USER:$ELASTIC_PASSWORD "$ELASTIC_HOST"/_security/user/"$ADMIN_LOGIN" \
    -H "Content-Type: application/json" \
    -d "{
        \"password\": \"$ADMIN_LOGIN_PASSWORD\",
        \"roles\": [\"superuser\"],
        \"full_name\": \"Admin user\"
    }"

    echo "New superuser created [$ADMIN_LOGIN - $ADMIN_LOGIN_PASSWORD]"

    # Wait to ensure security is fully operational
    while ! curl -s -u $ELASTIC_USER:$ELASTIC_PASSWORD "$ELASTIC_HOST"/_security/_authenticate >/dev/null; do
        sleep $RETRY_DELAY
    done

    echo "Elasticsearch security ready"

fi

# =================================================================================================
# Kibana
# =================================================================================================

if [ "$ELASTIC_STACK" == "1" ]; then

    echo "Starting Kibana..."

    # Start Kibana as the provided dedicated user
    su -s /bin/bash kibana -c "/usr/share/kibana/bin/kibana" &
    
    PIDS+=($!)
    echo "Kibana started with PID $!"

    # Wait for Kibana to be ready
    while ! curl -s "$KIBANA_HOST"/api/status | grep -q '"level":"available"'; do
        echo "Waiting for Kibana to become available..."
        sleep $RETRY_DELAY
    done

    echo "Kibana ready"

    # Create detection engine index
    curl -s -X POST "$KIBANA_HOST/api/detection_engine/index" \
    -u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    -H "kbn-xsrf: true"

    # Install prebuilt rules
    curl -s -X PUT "$KIBANA_HOST/api/detection_engine/rules/prepackaged" \
    -u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    -H "kbn-xsrf: true"

    # Enable ONLY network-related rules (simple and targeted)
    echo "Enabling network detection rules for: nmap, hping3, slowloris, ettercap, hydra..."
    
    #curl -s -X POST "$KIBANA_HOST/api/detection_engine/rules/_bulk_action" \
    #-u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    #-H "kbn-xsrf: true" \
    #-H "Content-Type: application/json" \
    #-d '{
    #    "action": "enable",
    #    "query": "alert.attributes.tags: \"Network\" OR alert.attributes.tags: \"network\""
    #}'

    #curl -s -X POST "$KIBANA_HOST/api/detection_engine/rules/_bulk_action" \
    #-u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    #-H "kbn-xsrf: true" \
    #-H "Content-Type: application/json" \
    #-d '{
    #    "action": "enable",
    #    "query": "alert.attributes.tags: \"Network\" OR alert.attributes.name: *Scan* OR alert.attributes.name: *Port* OR alert.attributes.name: *Brute* OR alert.attributes.name: *SSH* OR alert.attributes.name: *DoS* OR alert.attributes.name: *DDoS* OR alert.attributes.name: *Flood* OR alert.attributes.name: *ARP* OR alert.attributes.name: *Spoof* OR alert.attributes.name: *Slow* OR alert.attributes.name: *Hydra* OR alert.attributes.name: *Nmap*"
    #}'

    #echo -e "\nNetwork rules enabled"

    # Enable Suricata-specific rules if they exist
    #curl -s -X POST "$KIBANA_HOST/api/detection_engine/rules/_bulk_action" \
    #-u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    #-H "kbn-xsrf: true" \
    #-H "Content-Type: application/json" \
    #-d '{
    #    "action": "enable",
    #    "query": "alert.attributes.name: *Suricata*"
    #}'

    #echo -e "\nSuricata rules enabled"

    #curl -s -X POST "$KIBANA_HOST/api/detection_engine/rules/_bulk_action" \
    #-u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    #-H "kbn-xsrf: true" \
    #-H "Content-Type: application/json" \
    #-d '{
    #    "action": "enable",
    #    "query": "event.category:network"
    #}'

    #curl -s -X POST "$KIBANA_HOST/api/detection_engine/rules/_bulk_action" \
    #-u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    #-H "kbn-xsrf: true" \
    #-H "Content-Type: application/json" \
    #-d '{
    #    "action": "enable",
    #    "query": "event.module:suricata"
    #}'

    # First, create a custom rule that matches your Suricata data structure
    curl -u $ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD -X POST "$KIBANA_HOST/api/detection_engine/rules" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{
    "rule_id": "suricata_nmap_detection",
    "name": "Suricata Nmap Detection",
    "description": "Detects Nmap scans from Suricata alerts",
    "enabled": true,
    "risk_score": 47,
    "severity": "medium",
    "type": "query",
    "query": "suricata.eve.alert.signature: \"NMAP TCP Scan\"",
    "index": ["filebeat-*"]
    }'

    # Create a rule for flood/DoS detection
    curl -u $ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD -X POST "$KIBANA_HOST/api/detection_engine/rules" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{
    "rule_id": "suricata_flood_detection",
    "name": "Suricata Flood Detection",
    "description": "Detects potential flood/DoS attacks",
    "enabled": true,
    "risk_score": 73,
    "severity": "high",
    "type": "query",
    "query": "suricata.eve.alert.signature: *Flood* OR suricata.eve.alert.signature: *DoS*",
    "index": ["filebeat-*"]
    }'

    # Create threshold rule for DoS detection (high connection count)
    echo "Creating DoS threshold detection rule..."
    curl -u $ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD -X POST "$KIBANA_HOST/api/detection_engine/rules" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{
    "rule_id": "dos_flood_detection",
    "name": "Potential DoS/Flood Attack Detection",
    "description": "Detects potential DoS attacks by monitoring high volume of connections",
    "enabled": true,
    "risk_score": 73,
    "severity": "high",
    "type": "threshold",
    "query": "destination.ip: 192.168.10.10",
    "threshold": {
        "field": ["source.ip"],
        "value": 1000
    },
    "index": ["filebeat-*"],
    "interval": "5m",
    "from": "now-6m"
    }'

    # Create another threshold rule for port scan detection
    # Fix the port scan threshold rule
    echo "Creating port scan threshold detection..."
    curl -u $ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD -X POST "$KIBANA_HOST/api/detection_engine/rules" \
    -H "kbn-xsrf: true" \
    -H "Content-Type: application/json" \
    -d '{
        "rule_id": "port_scan_detection",
        "name": "Potential Port Scan Detection",
        "description": "Detects potential port scanning by monitoring connections to multiple ports",
        "enabled": true,
        "risk_score": 47,
        "severity": "medium",
        "type": "threshold",
        "query": "destination.ip: 192.168.10.10",
        "threshold": {
            "field": "source.ip",
            "value": 20,
            "cardinality": [
            {
                "field": "destination.port",
                "value": 5
            }
            ]
        },
        "index": ["filebeat-*"],
        "interval": "5m",
        "from": "now-6m"
    }'

    # Enable all Suricata alert rules
    #echo "Enabling Suricata alert rules..."
    #curl -s -X POST "$KIBANA_HOST/api/detection_engine/rules/_bulk_action" \
    #-u "$ADMIN_LOGIN:$ADMIN_LOGIN_PASSWORD" \
    #-H "kbn-xsrf: true" \
    #-H "Content-Type: application/json" \
    #-d '{
    #    "action": "enable",
    #    "query": "alert.attributes.name: *Suricata* OR alert.attributes.query: *suricata.eve*"
    #}'

    echo "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[READY]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]"

fi

# =================================================================================================
# Filebeat
# =================================================================================================

if [ "$SURICATA_SERVICE" == "1" ] && [ "$ELASTIC_STACK" == "1" ]; then

    # Fix permissions for the binded files
    echo "Setting Filebeat permissions..."

    chown root:root /etc/filebeat/filebeat.yml
    chmod 600 /etc/filebeat/filebeat.yml

    if [ -f /etc/filebeat/modules.d/suricata.yml ]; then
        chown root:root /etc/filebeat/modules.d/suricata.yml
        chmod 644 /etc/filebeat/modules.d/suricata.yml
    fi

    # Rather than changing on the configuration file, only start the specified modules
    echo "Enabling Filebeat modules..."

    if ! filebeat modules list | grep -q "^suricata.*enabled"; then
        filebeat modules enable suricata
        echo "Suricata module enabled"
    fi

    # Prepare Elastic to receive, parse and visualize logs correctly. It loads crucial elements like:
    # - Templates
    # - Ingest pipelines
    # - Pre-built dashboards
    echo "Running Filebeat setup..."

    filebeat setup \
    -E output.elasticsearch.username=$ELASTIC_USER \
    -E output.elasticsearch.password=$ELASTIC_PASSWORD \
    -E setup.kibana.host=$KIBANA_HOST

    echo "Filebeat setup completed"

    echo "Starting Filebeat..."

    # Start the filebeat service
    filebeat -e -c /etc/filebeat/filebeat.yml &

    PIDS+=($!)

    echo "Filebeat started with PID $!"



    #curl -s -u $ELASTIC_USER:$ELASTIC_PASSWORD "$ELASTIC_HOST"/_cat/indices?v

    #echo "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[READY2]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]"

fi

# =================================================================================================
# Process supervision
# =================================================================================================

# Only execute sleep if no background process is being executed
if [ ${#PIDS[@]} -gt 0 ]; then
    wait "${PIDS[@]}"
else
    sleep infinity
fi
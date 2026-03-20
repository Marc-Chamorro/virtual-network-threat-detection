#!/bin/bash
set -e
IFACE="${IFACE:-eth1}"
RETRY_DELAY=5
PIDS=()

# ================= NETWORK =================
while ! ip link show "${IFACE}" >/dev/null 2>&1; do
    sleep "$RETRY_DELAY"
done
ip addr add "$IP_ADDR" dev "$IFACE"
ip link set "$IFACE" up
ip route add "$IP_GTWY" dev "$IFACE"
ip link set "$IFACE" promisc on

# ================= SURICATA =================
if [ "$SURICATA_SERVICE" == "1" ]; then
    echo "Starting Suricata..."
    suricata -c /etc/suricata/suricata.yaml -i "$IFACE" &
    PIDS+=($!)
    sleep "$RETRY_DELAY"
fi

# ================= WAZUH =================
if [ "$WAZUH_STACK" == "1" ]; then
    echo "Starting Wazuh Indexer..."
    sysctl -w vm.max_map_count=262144
    chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer /var/lib/wazuh-indexer /var/log/wazuh-indexer 2>/dev/null || true
    su -s /bin/bash wazuh-indexer -c "OPENSEARCH_PATH_CONF=/etc/wazuh-indexer /usr/share/wazuh-indexer/bin/opensearch" &
    PIDS+=($!)

    echo "Waiting for Indexer..."
    while ! curl -s http://localhost:9200 >/dev/null 2>&1; do
        sleep "$RETRY_DELAY"
        echo "Waiting for Indexer..."
    done
    echo "Indexer ready"

    echo "Starting Wazuh Manager..."
    chown root:wazuh /var/ossec/etc/ossec.conf 2>/dev/null || true
    chmod 640 /var/ossec/etc/ossec.conf 2>/dev/null || true
    touch /var/log/suricata/eve.json
    chmod 644 /var/log/suricata/eve.json
    /var/ossec/bin/wazuh-control start
    sleep 10

    echo "Starting Dashboard..."
    mkdir -p /usr/share/wazuh-dashboard/data /usr/share/wazuh-dashboard/optimize
    chown -R wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data /usr/share/wazuh-dashboard/optimize 2>/dev/null || true
    su -s /bin/bash wazuh-dashboard -c "/usr/share/wazuh-dashboard/bin/opensearch-dashboards" &
    PIDS+=($!)

    echo "Waiting for Dashboard..."
    while ! curl -s http://localhost:5601/api/status >/dev/null 2>&1; do
        sleep "$RETRY_DELAY"
        echo "Waiting for Dashboard..."
    done
    echo "Dashboard ready"

    echo ""
    echo "========================================="
    echo "WAZUH STACK READY"
    echo "Access Dashboard: http://${IP_ADDR%%/*}:5601"
    echo "========================================="
fi

# ================= KEEP ALIVE =================
if [ ${#PIDS[@]} -gt 0 ]; then
    wait "${PIDS[@]}"
else
    sleep infinity
fi
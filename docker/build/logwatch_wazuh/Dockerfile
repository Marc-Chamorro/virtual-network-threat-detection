# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install traffic analysis tools
RUN apt-get update && apt-get install -y \
    iptables \
    iproute2 \
    tcpdump \
    net-tools \
    iputils-ping \
    procps \
    suricata \
    sudo \
    gnupg2 \
    apt-transport-https \
    curl \
    wget \
    vim \
    jq \
    openssl \
    systemd \
    systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# HACK: disable systemctl
RUN printf '#!/bin/sh\nexit 0\n' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl

RUN mkdir -p /etc/wazuh-indexer \
    /usr/share/wazuh-indexer \
    /var/lib/wazuh-indexer \
    /var/log/wazuh-indexer

# Add Wazuh GPG key
RUN mkdir -p /etc/apt/keyrings && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

# Add Wazuh repository
RUN echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

# Install Wazuh components
RUN apt-get update && apt-get install -y \
    wazuh-manager \
    wazuh-indexer \
    wazuh-dashboard \
    filebeat \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# FIX: Install Wazuh module for Filebeat properly
RUN mkdir -p /usr/share/filebeat/module && \
    curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.5.tar.gz | tar -xvz -C /usr/share/filebeat/module && \
    chmod -R 755 /usr/share/filebeat/module/wazuh

RUN suricata-update update-sources && \
    suricata-update --output /etc/suricata/rules/suricata.rules && \
    echo "Suricata rules downloaded: $(wc -l < /etc/suricata/rules/suricata.rules) lines"

# Create necessary directories and files
RUN mkdir -p /var/log/suricata /etc/suricata/rules /var/lib/filebeat && \
    touch /var/log/suricata/eve.json && \
    chmod 644 /var/log/suricata/eve.json && \
    echo '# Empty rule file' > /etc/suricata/rules/suricata.rules && \
    mkdir -p /usr/share/wazuh-dashboard/data && \
    chown -R wazuh-dashboard:wazuh-dashboard /usr/share/wazuh-dashboard/data 2>/dev/null || true

# In your Dockerfile, after installing wazuh-manager:
RUN mkdir -p /var/ossec/etc/lists/malicious-ioc && \
    touch /var/ossec/etc/lists/audit-keys \
    /var/ossec/etc/lists/malicious-ioc/malware-hashes \
    /var/ossec/etc/lists/malicious-ioc/malicious-ip \
    /var/ossec/etc/lists/malicious-ioc/malicious-domains \
    /var/ossec/etc/lists/amazon/aws-eventnames && \
    chown -R root:wazuh /var/ossec/etc/lists

# Copy entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
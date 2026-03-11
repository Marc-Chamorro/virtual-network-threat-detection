# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install traffic analysis tools
# procps -> sysctl
# suricata -> analyze traffic
# https://kifarunix.com/install-filebeat-8-on-debian/
# sudo gnupg2 apt-transport-https curl vim -> filebeat
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
    gpg --dearmor > /etc/apt/trusted.gpg.d/elk.gpg

RUN echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" \
    > /etc/apt/sources.list.d/elastic-8.list

RUN apt-get update && apt-get install -y \
    filebeat \
    elasticsearch \
    kibana \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN suricata-update

# Keep container running
# CMD ["sleep", "infinity"]
# CMD ["suricata", "-c", "/etc/suricata/suricata.yaml", "-i", "eth1"]

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
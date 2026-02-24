# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install traffic analysis tools
# procps -> sysctl
RUN apt-get update && apt-get install -y \
    iptables \
    iproute2 \
    tcpdump \
    net-tools \
    iputils-ping \
    sudo \
    procps \
    suricata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Keep container running
CMD ["sleep", "infinity"]
# CMD ["suricata", "-c", "/etc/suricata/suricata.yaml", "-i", "eth1"]
# Base image specific for firewall tasks
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary firewall and network tools
# conntrack is included for stateful firewall capabilities
# iptables is the core package filtering
# isc-dhcp-relay allows assigning IP addresses to other networks or VLANs
RUN apt-get update && apt-get install -y \
    iptables \
    iproute2 \
    net-tools \
    tcpdump \
    iputils-ping \
    procps \
    bridge-utils \
    conntrack \
    isc-dhcp-relay \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Execute the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
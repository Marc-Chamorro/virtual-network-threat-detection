# Base image specific for firewall tasks
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary firewall and network tools
# iptables - the core package filtering
# bridge-utils - provides brctl for creating Linux bridges used to merge VLAN trunk sub-interfaces into a single level 2 domain (e.g. br-vlan50 combining eth6.50 and eth7.50)
# conntrack - enables stateful packet inspection so return traffic from valid connections is permitted without explicit rules
# isc-dhcp-relay - DHCP relay agent that forwards client broadcast requests across VLAN boundaries to the centralized DHCP server

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
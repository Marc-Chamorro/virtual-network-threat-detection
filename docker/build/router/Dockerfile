# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install FRRouting and system tools
# frr - provides dynamic routing protocol (OSPF) used by all routers to exchange routes and simulate a realistic topology
# frr-pythontools - Python helper scripts required by FRR for vtysh CLI and for loading configuration files at startup
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    iptables \
    net-tools \
    tcpdump \
    procps \
    frr \
    frr-pythontools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Execute the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install bridge-utils for Layer 2 switching simulation, ot function like they are on the same network
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    net-tools \
    tcpdump \
    curl \
    procps \
    iptables \
    bridge-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Execute the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

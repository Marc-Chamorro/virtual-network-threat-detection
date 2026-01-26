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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Keep container running
CMD ["sleep", "infinity"]
# Base image
FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install management and observability tools
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    traceroute \
    net-tools \
    curl \
    tcpdump \
    nmap \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Keep the container alive
CMD ["sleep", "infinity"]
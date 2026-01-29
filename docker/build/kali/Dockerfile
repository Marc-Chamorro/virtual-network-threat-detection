# Base image for the Attacker Kali Linux setup
FROM kalilinux/kali-rolling

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install networking tools
# nmap: Port scanning
# openssh-client: For connecting to servers
# iproute2/net-tools: Interface management
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    traceroute \
    net-tools \
    curl \
    tcpdump \
    nmap \
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Keep the container alive
CMD ["sleep", "infinity"]

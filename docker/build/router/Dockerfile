# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install FRRouting and system tools
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

# Enable OSPF daemon by default in FRR configuration
RUN sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons

# Enable IP Forwarding persistently in sysctl.conf
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Keep the container alive
CMD ["sleep", "infinity"]
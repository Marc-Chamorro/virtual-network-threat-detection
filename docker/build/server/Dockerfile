FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    iproute2 \
    iputils-ping \
    net-tools \
    tcpdump \
    curl \
    procps \
    # SSH Server
    openssh-server \        
    # Web Server
    nginx \
    # DHCP Server
    isc-dhcp-server \
    # DNS Server
    # dnsmasq \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
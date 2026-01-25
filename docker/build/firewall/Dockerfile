FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -y install \
    iptables \
    iproute2 \
    net-tools \
    tcpdump \
    iputils-ping \
    procps \
    bridge-utils \
    # For connection tracking, allows stateful firewall rules
    conntrack \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
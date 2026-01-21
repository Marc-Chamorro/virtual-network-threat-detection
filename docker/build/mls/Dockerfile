FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -y install \
    iproute2 \
    iputils-ping \
    net-tools \
    tcpdump \
    curl \
    procps \
    iptables \
    # Connect multiple network interfaces, to function like they are on the same network
    bridge-utils \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    iptables \
    iproute2 \
    tcpdump \
    net-tools \
    iputils-ping \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

CMD ["sleep", "infinity"]
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt -y install \
    iproute2 \
    iputils-ping \
    iptables \
    net-tools \
    tcpdump \
    procps \
    frr \
    frr-pythontools \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

# enable OSPF
RUN sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons

RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

CMD ["sleep", "infinity"]
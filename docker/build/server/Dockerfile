# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install server daemons and system tools
# openssh-server: Remote access
# nginx: Web server
# isc-dhcp-server: Dynamic host configuration
# dnsmasq: DNS Service
# vsftpd: FTP Service
# postfix: email sender
# dovecot: email destination tray (don't install POP3)
# mailutils: mail tools
RUN apt-get update && apt-get install -y \
    iproute2 \
    iputils-ping \
    net-tools \
    tcpdump \
    curl \
    procps \
    openssh-server \
    nginx \
    vim \
    isc-dhcp-server \
    dnsmasq \
    vsftpd \
    postfix \
    dovecot-core \
    dovecot-imapd \
    mailutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Execute the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
# Base image
FROM debian:12-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install server daemons and system tools
# openssh-server - SSH daemon providing remote access
# isc-dhcp-server - DHCP server that dynamically assigns IP addresses, gateways and DNS settings
# nginx - basic web server
# dnsmasq - DNS server providing hostname resolution
# vsftpd - FTP server with individual user chroot isolation
# postfix - SMTP mail transfer agent used both as enterprise relay server and central internet mail hub
# dovecot-core - package providing the framework for the IMAP mail server
# dovecot-imapd - daemon that allows mail clients (mutt) to retrieve messages from user Maildir directories
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Directory for all the users used
RUN mkdir -p /mail-users

# Execute the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
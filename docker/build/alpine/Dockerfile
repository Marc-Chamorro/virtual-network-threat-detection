# Base image specific for network tasks
FROM wbitt/network-multitool:alpine-extra

# Install additional tools if necessary (keeping it minimal)
# dhcpcd allows to request IP by DHCP (client)
# lftp uss FTP service as client
# msmtp SMTP email sender
# mutt IMAP & POP3
RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    net-tools \
    dhcpcd \
    lftp \
    msmtp \
    mutt \
    && rm -rf /var/cache/apk/*

# Necessary folder for mutt not created automatically
RUN mkdir -p /root/.mutt

# Default command to keep the container running
CMD ["sleep", "infinity"]


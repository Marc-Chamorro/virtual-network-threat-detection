# Base image specific for network tasks
FROM wbitt/network-multitool:alpine-extra

# Install additional tools if necessary (keeping it minimal)
# dhcpcd allows to request IP by DHCP (client)
# lftp uss FTP service as client
# mutt mail user agent
RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    net-tools \
    dhcpcd \
    lftp \
    mutt \
    && rm -rf /var/cache/apk/*

# Necessary folder for mutt not created automatically
RUN mkdir -p /root/.mutt

# Copy entrypoint script and set executable permissions
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Execute the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]

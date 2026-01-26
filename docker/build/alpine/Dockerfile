# Base image specific for network tasks
FROM wbitt/network-multitool:alpine-extra

# Install additional tools if necessary (keeping it minimal)
RUN apk update && apk add --no-cache \
    net-tools \
    && rm -rf /var/cache/apk/*

# Default command to keep the container running
CMD ["sleep", "infinity"]
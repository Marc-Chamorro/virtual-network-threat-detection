# Base image specific for network tasks
FROM wbitt/network-multitool:alpine-extra

# Install additional tools if necessary (keeping it minimal)
# dhcpcd allows to request IP by DHCP (client)
RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    net-tools \
    dhcpcd \
    lftp \
    && rm -rf /var/cache/apk/*

# Default command to keep the container running
CMD ["sleep", "infinity"]

    # pc_vlan50_1:/# echo "hola ftp" > test.txt
    # lftp user5_1@internal.enterprise.local
    # put test.txt
    
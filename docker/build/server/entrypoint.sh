#!/bin/bash

set -e

# Default Credentials
SSH_USER=vntd
SSH_PASS=pswd

# SSH Server
if [ "$SSH_SERVER" == "1" ]; then
    # Create a new user for SSH access
    useradd $SSH_USER -s /bin/bash -M
    # Set the password for the new user
    echo "$SSH_USER:$SSH_PASS" | chpasswd

    # Configure SSH for password authentication
    sed -i '/PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
    sed -i '/PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config

    # Allow SSH access for the created user
    echo "Match User $SSH_USER" >> /etc/ssh/sshd_config
    echo "    PasswordAuthentication yes" >> /etc/ssh/sshd_config
    
    # Start the ssh service
    service ssh start
fi

# Web Server
if [ "$WEB_SERVER" == "1" ]; then
    # Add a simple web page
    echo 'Hello from Nginx on the web server' > /var/www/html/index.nginx-debian.html
    # Start Nginx
    service nginx start
    #nginx -g 'daemon off;'
fi

# DHCP Server
if [ "$DHCP_SERVER" == "1" ]; then

    # Wait until eth1 exists, otherwise it can make DHCP crash
    while ! ip link show "${IFACE}" >/dev/null 2>&1; do
        sleep 1
    done

    # Wait until eth1 has an IP address assigned
    while ! ip addr show "${IFACE}" | grep -q "${IP_ADDR}"; do
        sleep 1
    done

    # Start the DHCP service
    service isc-dhcp-server start
fi

# DNS Server
if [ "$DNS_SERVER" == "1" ]; then
    # Start the DNS service
    dnsmasq
fi

# NFS | SMB | FTP - NAS


# Keep the container alive
sleep infinity

#!/bin/bash

set -e

# Default Credentials
SSH_USER=vntd
SSH_PASS=pswd

# SSH Server
if [[ "$SSH_SERVER" == "1" ]]; then
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
if [[ "$WEB_SERVER" == "1" ]]; then
    # Add a simple web page
    echo 'Hello from Nginx on the web server' > /var/www/html/index.nginx-debian.html
    # Start Nginx in the foreground since we sleep at the end
    nginx -g 'daemon off;'
fi

# DHCP Server
#if [[ "$ENABLE_DHCP" == "1" ]]; then
#    echo "Starting DHCP"
#    service isc-dhcp-server start
#fi

# Keep the container alive
sleep infinity

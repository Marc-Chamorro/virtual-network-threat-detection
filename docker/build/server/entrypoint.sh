#!/bin/bash

set -e

echo "Starting services"

SSH_USER=vntd
SSH_PASS=pswd

if [[ "$SSH_SERVER" == "1" ]]; then
    echo "Starting SSH"
    useradd $SSH_USER -s /bin/bash -M
    echo "$SSH_USER:$SSH_PASS" | chpasswd

    sed -i '/PasswordAuthentication/c\PasswordAuthentication yes' /etc/ssh/sshd_config
    sed -i '/PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config

    echo "Match User $SSH_USER" >> /etc/ssh/sshd_config
    echo "    PasswordAuthentication yes" >> /etc/ssh/sshd_config
    service ssh start
fi

if [[ "$WEB_SERVER" == "1" ]]; then
    echo "Starting NGINX"
    echo 'Hello from Nginx on the web server' > /var/www/html/index.nginx-debian.html
    nginx -g 'daemon off;' # Run the server on the background
fi

#if [[ "$ENABLE_DHCP" == "1" ]]; then
#    echo "Starting DHCP"
#    service isc-dhcp-server start
#fi

echo "Services started"

sleep infinity

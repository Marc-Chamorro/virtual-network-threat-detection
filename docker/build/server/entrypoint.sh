#!/bin/bash

set -e

# SSH Server
if [ "$SSH_SERVER" == "1" ]; then
    # Default Credentials
    SSH_USER=vntd
    SSH_PASS=pswd

    if ! id "$SSH_USER" >/dev/null 2>&1; then
        # Create a new user for SSH access
        useradd $SSH_USER -s /bin/bash -M
        # Set the password for the new user
        echo "$SSH_USER:$SSH_PASS" | chpasswd
    fi

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
    # This command waits for the IFACE to exist, '>/dev/null' makes it so that nothing is printed on screen and '2>&1' also hides any possible errors
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

# FTP - NAS
if [ "$FTP_SERVER" == "1" ]; then
    FTP_ROOT_DIR="/ftp"
    FTP_PASS="pswd"
    FTP_USERS_FILE="/etc/vsftpd.chroot_list"

    # Modify permissions for the configuration file (otherwise, the system won't start)
    chown root:root /etc/vsftpd.conf
    chmod 644 /etc/vsftpd.conf

    # The user's won't be able to log in, but can FTP (/shells reference the nologin file)
    echo "/sbin/nologin" >> /etc/shells

    # Create the directory (full path)
    mkdir -p "$FTP_ROOT_DIR"
    # Make root owner of the root FTP directory
    chown root:root "$FTP_ROOT_DIR"
    # Owner full access and contro, other users see and navigate
    chmod 755 "$FTP_ROOT_DIR"

    # If the user file exists, create the users
    if [ -f "$FTP_USERS_FILE" ]; then

        while read USER; do

            # Avoid empty lines / comments
            if [ "$USER" = "" ] || [ "$(echo "$USER" | cut -c1)" = "#" ]; then
                continue
            fi

            # If the user does exist, do not print the regarding information
            if ! id "$USER" >/dev/null 2>&1; then
                FTP_USER_DIR="$FTP_ROOT_DIR/$USER"

                # Create a new user (create the new users home directory in the specified path) (disable login on the server)
                useradd -m -d "$FTP_USER_DIR" -s /sbin/nologin "$USER"
                # Set the password for the new user
                echo "$USER:$FTP_PASS" | chpasswd
                #chown "$USER":"$FTP_GROUP" "$FTP_USER_DIR"
                chmod 700 "$FTP_USER_DIR"
            fi

        done < "$FTP_USERS_FILE"

    fi

    # Start the FTP service
    service vsftpd start
fi

# Mail Server
if (( MAIL_SERVER + MAIN_MAIL_SERVER == 1 )); then

    # POSTFIX
    # The main mail server relies on two additional configuration files
    if [ "$MAIN_MAIL_SERVER" = "1" ]; then
        chown root:root /etc/postfix/transport
        chmod 644 /etc/postfix/transport
        postmap /etc/postfix/transport

        chown root:root /etc/postfix/relay_recipients
        chmod 644 /etc/postfix/relay_recipients
        postmap /etc/postfix/relay_recipients
    fi

    chown root:root /etc/postfix/main.cf
    chmod 644 /etc/postfix/main.cf

    postfix start

    # DOVECOT
    create_users_from_dir() {
        BASE_DIR="$1"

        if ! [ -d "$BASE_DIR" ]; then
            return
        fi

        for USER_PATH in "$BASE_DIR"/*; do
            if [ ! -f "$USER_PATH" ]; then
                continue
            fi

            USER=$(basename "$USER_PATH")

            if [ -z "$USER" ]; then
                continue
            fi

            # Create user only if it does not exist
            if ! id "$USER" >/dev/null 2>&1; then
                useradd -m -s /sbin/nologin "$USER"
                echo "$USER:$USER" | chpasswd
                maildirmake.dovecot /home/"$USER"/Maildir
                chown -R "$USER:$USER" /home/"$USER"/Maildir
                echo "USER CREATED"
            fi

        done
    }

    # DMZ only
    if [ "$MAIL_SERVER" = "1" ]; then
        create_users_from_dir /mail-users/enterprise
    fi

    # Internet Only
    if [ "$MAIN_MAIL_SERVER" = "1" ]; then
        create_users_from_dir /mail-users/internet
    fi

    service dovecot start
fi

# Keep the container alive
sleep infinity

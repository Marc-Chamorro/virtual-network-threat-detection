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

# NFS | SMB | FTP - NAS

if [ "$FTP_SERVER" == "1" ]; then
    FTP_ROOT_DIR="/ftp"
    #FTP_GROUP="ftpusers"
    FTP_PASS="pswd"
    FTP_USERS_FILE="/etc/vsftpd.chroot_list"

    chown root:root /etc/vsftpd.conf
    chmod 644 /etc/vsftpd.conf

    # The user's won't be able to log in, but can FTP
    echo "/sbin/nologin" >> /etc/shells

    # Only create the group if it has not been previously created
    #if ! getent group "$FTP_GROUP" >/dev/null; then
    #    groupadd "$FTP_GROUP"
    #fi

    # Create the shared directory (full path)
    mkdir -p "$FTP_ROOT_DIR"
    #mkdir -p "$FTP_USERS_DIR"
    #mkdir -p "$FTP_SHARED_DIR"

    # Make user:group owners of the root FTP directory
    chown root:root "$FTP_ROOT_DIR"
    # Owner full access and contro, other users see and navigate
    chmod 755 "$FTP_ROOT_DIR"

    # Make the shared directoy owner the new group
    #chown root:"$FTP_GROUP" "$FTP_SHARED_DIR"
    # Owner, group owner full control, and others read and execute (view and navigate)
    #chmod 775 "$FTP_SHARED_DIR"

    #echo "This is a shared file" > "$FTP_SHARED_DIR/test.txt"

    # Ensue the user list files exist
    #if [ ! -f "$FTP_USERS_FILE" ]; then
    #    echo "ERROR: $FTP_USERS_FILE not found"
    #    exit 1
    #fi

    # If the user file exists, create the users
    if [ -f "$FTP_USERS_FILE" ]; then

        while read USER; do

            if [ "$USER" = "" ]; then
                continue
            fi

            FIRST_CHAR=$(echo "$USER" | cut -c1)

            if [ "$FIRST_CHAR" = "#" ]; then
                continue
            fi

            # If the user does exist, do not print the regarding information
            if ! id "$USER" >/dev/null 2>&1; then
                FTP_USER_DIR="$FTP_ROOT_DIR/$USER"

                # Create a new user (create the new users home directory in the specified path) (disable login on the server)
                # useradd -m -d "$FTP_USER_DIR" -s /sbin/nologin -G "$FTP_GROUP" "$USER"
                useradd -m -d "$FTP_USER_DIR" -s /sbin/nologin "$USER"
                # Set the password for the new user
                echo "$USER:$FTP_PASS" | chpasswd
                
                #chown "$USER":"$FTP_GROUP" "$FTP_USER_DIR"
                chmod 700 "$FTP_USER_DIR"

                #mkdir -p "$FTP_USER_DIR/shared"
                #mount --bind "$FTP_SHARED_DIR" "$FTP_USER_DIR/shared"

                #mkdir -p "$FTP_USER_DIR/shared"
                #cp -r "$FTP_SHARED_DIR/"* "$FTP_USER_DIR/shared/"
                # Everything copied is owned by the user
                #chown -R "$USER":"$FTP_GROUP" "$FTP_USER_DIR/shared"
                # Everything copied, has 770 access
                #chmod -R 770 "$FTP_USER_DIR/shared"

            fi

        done < "$FTP_USERS_FILE"

    fi

    service vsftpd start

fi

# Keep the container alive
sleep infinity

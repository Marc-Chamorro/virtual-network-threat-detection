#!/bin/bash

set -e

# MUTT Configuration (MAIL Service)
if [ "$MUTT_CLIENT" == "1" ]; then
    MUTT_HOME="/root"   # We assume all end users are root for this environment
    mkdir -p "$MUTT_HOME/.mutt/cache/headers"
    mkdir -p "$MUTT_HOME/.mutt/cache/bodies"
    touch "$MUTT_HOME/.mutt/certificates"
fi

# Network Configuration
if [ "$DHCP_CLIENT" == "1" ]; then

    IFACE="${IFACE:-eth1}"
    RETRY_DELAY=5

    ip link set "$IFACE" up

    # Delete the default route assigned by Containerlab
    ip route del default

    while true; do
        # https://man.archlinux.org/man/dhcpcd.8.en
        # -4 -> IPv4 only
        # -w -> wait for IPv4 before continuing
        # -1 -> exit after configuration
        # -B -> do not background
        # -L -> prevent automatic IP address assignment from being considered as successful
        if dhcpcd -4 -w "$IFACE"; then
            # DHCP Acquired, exit the loop
            break
        fi

        # In case it fails, wait
        sleep "$RETRY_DELAY"
    done
fi

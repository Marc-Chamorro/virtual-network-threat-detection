#!/bin/bash

set -e

# Enable OSPF daemon by default in FRR configuration
sed -i 's/ospfd=no/ospfd=yes/' /etc/frr/daemons

# Enable IP forwarding to allow traffic routing
sysctl -w net.ipv4.ip_forward=1

# Start the FRR service
/usr/lib/frr/frrinit.sh start

# Keep the container alive
sleep infinity
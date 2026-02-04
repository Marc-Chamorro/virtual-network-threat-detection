# DHCP Server Configuration

This document details the **configuration and behavior** of the DHCP server used in the VNTD lab.

The server provides address assignment and network parameters to all user endpoints via the firewall relay.

## Server Placement

The DHCP server runs on a dedicated internal service node:

- **Node:** `internal_server`
- **VLAN:** 40 (Internal Services)
- **IP Address:** `192.168.40.10`

This placement ensures controlled access and avoids direct exposure to user or external networks.

## DHCP Software

The service is implemented using:

- **ISC DHCP Server (`isc-dhcp-server`)**

This choice provides:
- Mature feature support
- Clear configuration syntax
- Detailed logging for debugging

## Interface Binding

The server is explicitly bound to a single interface:

- Interface: `eth1`

This prevents the DHCP daemon from listening on unintended interfaces and reinforces segmentation.

Configuration is defined in:

- `/etc/default/isc-dhcp-server`
- `/etc/dhcp/dhcpd.conf`

## Address Pools

Dedicated address pools are defined for each user VLAN:

- **VLAN 50:** `192.168.50.0/24`
- **VLAN 60:** `192.168.60.0/24`

Each pool specifies:

- IP address range
- Subnet mask
- Default gateway (firewall)
- DNS server(s)
- Lease duration

This ensures consistent behavior across all user floors.

## DNS and Gateway Distribution

As part of the DHCP lease, clients receive:

- The firewall IP as default gateway
- The internal DNS server address

This ensures:
- Centralized routing
- Uniform name resolution
- No manual client configuration

## Configuration Management

All DHCP configuration files are:

- Stored under the project `config/` directory
- Mounted into the container at runtime

!!! warning
    Changes made directly inside the running container are **not persistent** and will be lost on redeployment.

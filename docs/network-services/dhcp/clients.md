# DHCP Client Behavior

This document describes how **client nodes** obtain and apply network configuration using DHCP.

Clients are designed to be minimal, automated, and representative of real enterprise endpoints.

## Client Scope

DHCP clients include:

- User workstations in VLAN 50
- User workstations in VLAN 60

These nodes simulate employee devices connecting to the enterprise network.

## Startup Process

Each client executes a startup script at container launch.

The script performs:

- Interface activation
- DHCP request for IPv4 configuration
- Automatic application of routing and DNS settings

This ensures that clients are fully operational without manual intervention.

## Lease Application

Once a lease is obtained, the client automatically applies:

- Assigned IP address
- Subnet configuration
- Default gateway
- DNS resolver

This mirrors the behavior of real operating systems in enterprise environments.

## Network Dependency

Client connectivity depends on:

- Correct firewall relay configuration
- Active DHCP server
- Allowed DHCP traffic in firewall policies

If any of these components fail, clients will not obtain network access.

## Local Inspection Tools

Although testing is documented elsewhere, clients can inspect their state using:

- `ip addr`
- `ip route`
- `dhcpcd`

These tools are useful for understanding applied configuration.

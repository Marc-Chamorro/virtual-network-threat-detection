# DHCP Client Behavior

This document describes how **client nodes** obtain and apply network configuration using DHCP.

Clients are designed to be minimal, automated, and representative of real enterprise endpoints.

---

## Client Scope

DHCP clients include:

- User workstations in VLAN 50.
- User workstations in VLAN 60.

These nodes simulate employee devices connecting to the enterprise network.

---

## Startup Process

Each client executes a startup script at container launch.

The script performs:

- Interface activation.
- DHCP request for IPv4 configuration.
- Automatic application of routing and DNS settings.

This ensures that clients are fully operational without manual intervention.

---

## Usage

To make use of the startup script in the `alpine_vntd` end users, proceed with the following steps:

1. Bind the startup script required for the machine to use DHCP.

```yml
binds:
    - ./config/pc/startup.sh:/startup.sh
```

2. Execute the script:

```yml
exec:
    - sh /startup.sh
```

---

## Making use of DHCP service

Once the DHCP the service is obtained, the client automatically:

- Assigns an IP address.
- Configures the subnet.
- Sets a default gateway.
- Assigns a DNS server.

This mirrors the behavior of real operating systems in enterprise environments.

---

## Network Dependency

Client connectivity depends on:

- Correct firewall relay configuration.
- Active DHCP server.
- Allowed DHCP traffic in firewall policies.

If any of these components fail, clients will not obtain network access.

---

## Local Inspection Tools

Clients can inspect their state using:

- `ifconfig`

This tool is useful for understanding applied configuration.

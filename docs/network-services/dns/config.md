# DNS Server Configuration

This document describes the configuration of the DNS server used in the VNTD lab.

The configuration focuses on clarity, explicit behavior, and ease of debugging.

## Server Placement

The DNS server runs on a dedicated node in the DMZ:

- **Node:** `dmz_server`
- **VLAN:** 10
- **IP Address:** `192.168.10.10`

This node also hosts other DMZ services, but DNS is logically isolated at the configuration level.

## DNS Software

The service is implemented using:

- **BIND9**

BIND provides:
- Authoritative and recursive capabilities
- Fine-grained access control
- Predictable and well-documented behavior

## Listening Interfaces

The DNS daemon is explicitly configured to:

- Listen only on the DMZ interface
- Avoid binding to unintended addresses

This reduces the attack surface and enforces correct traffic paths.

## Zone Configuration

The DNS server defines:

- **Internal zones** for enterprise services
- Host records for DMZ and internal servers

These zones are authoritative and resolved locally without forwarding.

## Forwarding Configuration

For domains outside defined zones:

- Queries are forwarded to an external DNS server
- Forwarding is restricted by firewall policy

This ensures that all external name resolution is centralized and observable.

## Configuration Management

All DNS configuration files are:

- Stored under the project `config/` directory
- Mounted into the container at startup

!!! warning
    Changes made inside the running container are not persistent and will be lost on redeployment.

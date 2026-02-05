# DNS Resolution Flow

This document describes the **DNS resolution paths** within the VNTD lab and how queries traverse the network.

## Client Scope

DNS clients can be any device with access to a DNS server. Devices in the network need to either manually add the DNS address or receive it through DHCP.

**DNS Manual Assignment**
- Attacker
- Benign
- Administrator

**DHCP Assignment**
- PC VLAN 50 1 & 2
- PC VLAN 50 1 & 2

DNS address assignment  does not rely on a working DNS server. Assignment can be made nonetheless, but the service won't work.

## Manual Assignment

The easiest way to manage and make a network node use a DNS server is to directly assign it to them through the `topology` file.

```yml
dns:
    servers:
        - 172.16.100.100
```

This way, addresses can be easily managed and modified without resorting to scripting or startup files.

## DHCP Assignment

For devices receiving service from a DHCP server, the way to go is to wait for the DHCP server to offer the already configured in within DNS addresses into the devices connectivity settings.

!!! important
    Given that the DHCP service is not working, not only won't these devices receive an IP address, but also a DNS address.

## Local Inspection Tools

Clients can inspect their state using:

- `ifconfig`

This tool is useful for understanding applied configuration.
---
title: DNS Resolution Flow
icon: material/arrow-decision
---

# DNS Resolution Flow

This page describes how **DNS queries** traverse the VNTD network based on the source and the requested domain.

---

## Internal Client Flow (VLAN 50/60)

When an internal workstation attempts to resolve a name, the following process occurs:

1.  **Client:** Consults `/etc/resolv.conf` (updated automatically by DHCP) and sends a query to `192.168.10.10`.
2.  **Firewall:** Forwards the DNS packet (UDP/53) from the user VLAN to the DMZ.
3.  **DMZ Server:**
    - If the name is known by the server, it responds directly.
    - If the name is **NOT** known by the server,, it forwards the query to `172.16.100.100`.
4.  **Firewall & Router:** Perform NAT/Routing to reach the Internet Core.
5.  **ISP Server:** Responds to the query.

---

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

---

## Manual Assignment

The easiest way to manage and make a network node use a DNS server is to directly assign it to them through the `topology` file.

!!! example "DNS manual assignment"
```yml
dns:
    servers:
        - 172.16.100.100
```

This way, addresses can be easily managed and modified without resorting to scripting or startup files.

---

## DHCP Assignment

For devices receiving service from a DHCP server, the way to go is to wait for the DHCP server to offer the already configured in within DNS addresses into the devices connectivity settings.

!!! important "DHCP provides DNS"
    Given that the DHCP service is not working, not only won't these devices receive an IP address, but also a DNS address.

!!! question "Check IP"
    Clients can inspect their state using: `ifconfig`
    This tool is useful for understanding applied configuration.

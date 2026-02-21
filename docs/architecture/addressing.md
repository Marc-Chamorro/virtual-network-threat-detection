---
title: Addressing & VLANs
icon: material/ip-network
---

# Addressing & VLANs

The VNTD laboratory uses a predictable **IPv4 addressing scheme** designed to simplify debugging and align with common enterprise practices.

---

## VLAN and Subnet Mapping

Every enterprise function is mapped to a dedicated VLAN and subnet, with the Firewall serving as the gateway. External networks use distinct address spaces to avoid overlap.

| VLAN   | Name / Purpose          | Subnet              | Gateway           |
|:-------|:------------------------|:--------------------|:------------------|
| **-**  | Router - Router         | 172.16.x.0/30       | —                 |
|        |                         |                     |                   |
| **-**  | Internet Core           | 172.16.100.0/24     | 172.16.100.1      |
| **-**  | Attacker Network        | 10.0.0.0/24         | 10.0.0.1          |
| **-**  | Benign Network          | 20.0.0.0/24         | 20.0.0.1          |
|        |                         |                     |                   |
| **10** | DMZ                     | 192.168.10.0/24     | 192.168.10.1      |
| **20** | Monitoring & IDS        | 192.168.20.0/24     | 192.168.20.1      |
| **30** | Administration          | 192.168.30.0/24     | 192.168.30.1      |
| **40** | Internal Services       | 192.168.40.0/24     | 192.168.40.1      |
| **50** | User Floor 1 & 2        | 192.168.50.0/24     | 192.168.50.1      |
| **60** | User Floor 1 & 2        | 192.168.60.0/24     | 192.168.60.1      |

!!! note "IPv6"
    IPv6 is intentionally out of scope for this project.

---

## Gateway

For all enterprise VLANs:

- The firewall interface is the default gateway.
- No direct routing exists between VLANs.
- NAT and forwarding decisions are centralized.

!!! note
    This design simplifies troubleshooting and ensures all inter-zone traffic is visible from a single point.

---

## IP Assignment Strategy

The project employs a hybrid model for IP assignment to reflect realistic corporate environments.

=== "Static Assignment"

    Used for core infrastructure nodes to ensure reliability:

    - **Routers & Firewalls:** Manually configured in startup scripts.
    - **Servers:** DMZ and Internal servers use fixed IPs (e.g., `192.168.10.10`).

=== "Dynamic Assignment (DHCP)"

    Used for end-user workstations in VLANs 50 and 60:
    
    - **Server:** Centrally managed by `internal_server` (VLAN 40).
    - **Relay:** The Firewall hosts the `isc-dhcp-relay` service to bridge requests across VLANs.

---

## DNS Addressing Considerations

DNS servers are intentionally placed in different zones, which allows testing of internal vs external name resolution services.

- Internal DMZ DNS: `dmz_server`
- External DNS: `internet_server`

## DNS Infrastructure

DNS servers are intentionally placed in different zones, which allows testing of internal vs external name resolution services.
- **Internal DNS (`dmz_server`):** Resolves local hostnames and forwards unknown requests to the internet server.
- **External DNS (`internet_server`):** Simulates public DNS service.

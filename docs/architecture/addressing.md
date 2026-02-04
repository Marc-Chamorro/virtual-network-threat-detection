# Addressing & VLANs

This page documents **IP addressing** and **VLAN segmentation strategy** used in the VNTD lab.

The IP addressing is designed to be:

- Predictable.
- Easy to debug.
- Aligned with common enterprise practices and expected behaviors.

## Addressing

The project uses **IPv4 addressing** throughout the enterprise environment, with clearly separated subnets for each function. Each subnet:

- Maps to a single VLAN.
- Has a dedicated default gateway on the firewall.
- Is documented explicitly in configuration files.

External networks use distinct address spaces to avoid overlap.

## VLAN and Subnet Mapping

| VLAN | Name / Purpose          | Subnet              | Gateway           |
|-----:|-------------------------|---------------------|-------------------|
| —    | Attacker Network        | 10.0.0.0/24         | 10.0.0.1          |
| —    | Benign Network          | 20.0.0.0/24         | 20.0.0.1          |
| —    | Internet Core           | 172.16.100.0/24     | 172.16.100.1      |
| 10   | DMZ                     | 192.168.10.0/24     | 192.168.10.1      |
| 20   | Monitoring & IDS        | 192.168.20.0/24     | 192.168.20.1      |
| 30   | Administration          | 192.168.30.0/24     | 192.168.30.1      |
| 40   | Internal Services       | 192.168.40.0/24     | 192.168.40.1      |
| 50   | User Floor 1 & 2        | 192.168.50.0/24     | 192.168.50.1      |
| 60   | User Floor 1 & 2        | 192.168.60.0/24     | 192.168.60.1      |

## Gateway

For all enterprise VLANs:

- The firewall interface is the default gateway.
- No direct routing exists between VLANs.
- NAT and forwarding decisions are centralized.

!!! note
    This design simplifies troubleshooting and ensures all inter-zone traffic is visible from a single point.

## Static vs Dynamic Addressing

- **Static IPs** are used for:
  - Routers
  - Firewalls
  - Servers
  - Monitoring devices

- **Dynamic IPs (DHCP)** are used for:
  - User workstations (VLAN 50 and 60)

This hybrid solution reflects real-world enterprise environments. The DHCP device in charge of managing the DHCP service is `internal_server`.

## DNS Addressing Considerations

DNS servers are intentionally placed in different zones, which allows testing of internal vs external name resolution services.

- Internal DMZ DNS: `dmz_server`
- External DNS: `internet_server`

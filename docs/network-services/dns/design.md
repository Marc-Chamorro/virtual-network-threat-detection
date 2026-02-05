# DNS Service Design

This document describes the **design and placement** of the DNS service within the Virtual Network Threat Detection lab.

DNS is a critical infrastructure service that enables name-based communication while respecting network segmentation and security boundaries.

## Purpose of DNS in the Lab

The DNS service is responsible for:

- Resolving hostnames for internal enterprise services
- Supporting user access to DMZ-hosted resources
- Forwarding unresolved queries to external DNS servers
- Simulating realistic enterprise name resolution behavior

DNS is required for both usability and realism, as most applications rely on name resolution rather than raw IP addresses.

## Architectural Placement

The DNS server is deployed in the **DMZ (VLAN 10)** and in the **Internet Server**.

This placement reflects a common enterprise pattern where:

- DNS is reachable by internal users
- DNS can communicate with other external resolvers
- Exposure is controlled through firewall policies

The DNS service within the enterprise is not directly accessible from the Internet. However, the external one can be accessed by the internal one.

## Design Constraints

The DNS design follows these constraints:

- VLANs are isolated at Layer 3
- All DNS traffic must traverse the firewall
- All DNS requests are managed by the `Internal Server`
- External resolution is managed by the `Internal Server`

These constraints ensure visibility and control over all name resolution activity.

This **hybrid DNS model** allows for the following:

- **Authoritative resolution** for internal zones and known domains.
- **Recursive forwarding** for unknown external domains (Internet domains)

This allows internal services to be resolved, managed and optimized locally while still enabling Internet access.

## Integration with DHCP

DNS and DHCP are intentionally coupled:

- DHCP provides the DNS server address to clients
- Clients do not configure resolvers manually
- DNS behavior is consistent across all user VLANs

## Security Considerations

DNS is treated as a policy-controlled service:

- Only permitted clients may query the DNS server
- Only the DNS server may forward queries externally
- DNS traffic leaving the enterprise network is visible for inspection and analysis in the Monitoring zone.

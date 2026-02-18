---
title: DNS Service Design
icon: material/dns-outline
---

# DNS Service Design

TNS is a critical infrastructure service that provides hostname resolution for internal enterprise services and simulated external internet resources while respecting network segmentation and security boundaries.

---

## Purpose of DNS in the Lab

The DNS service is responsible for:

- Resolving hostnames for internal enterprise services.
- Supporting user access to DMZ-hosted resources.
- Forwarding unresolved queries to external DNS servers.
- Simulating realistic enterprise name resolution behavior.

DNS is required for both usability and realism, as most applications rely on name resolution rather than raw IP addresses.

---

## Hybrid DNS Model

The DNS design needs to consider these constraints:

- VLANs are isolated at Layer 3.
- All DNS traffic must traverse the firewall.
- All DNS requests are managed by the `Internal Server`.
- External resolution is managed by the `Interent Server`.

These ensure visibility and control over all name resolution activity.

Therefore, the lab employs a **hybrid resolution model** to ensure both local efficiency and realistic internet behavior:

- **Authoritative resolution:** The internal server resolves local domains like `enterprise.local`.
- **Recursive forwarding:** Requests for unknown domains are forwarded to the simulated internet resolver.

This allows internal services to be resolved, managed and optimized locally while still enabling Internet access.

---

## Placement Strategy

DNS services are deployed in two distinct locations:

| Resolver         | Node              | Zone          | Role                                   |
|:-----------------|:------------------|:--------------|:---------------------------------------|
| **Internal DNS** | `dmz_server`      | DMZ (VLAN 10) | Primary resolver for enterprise users. |
| **External DNS** | `internet_server` | ISP Core      | Simulated public internet DNS.         |


This placement reflects a common enterprise pattern where:

- DNS is reachable by internal users.
- DNS can communicate with other external resolvers.
- Exposure is controlled through firewall policies.

The DNS service within the enterprise is not directly accessible from the Internet. However, the external one can be accessed by the internal one.

---

## Integration with DHCP

DNS and DHCP are intentionally coupled:

- DHCP provides the DNS server address to clients (DMZ Server).
- Clients do not configure resolvers manually.
- DNS behavior is consistent across all user VLANs.

!!! note "DHCP Coupling"
    This dependency is intentional and mirrors common enterprise environments.

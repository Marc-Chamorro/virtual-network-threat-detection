---
title: Network Services Overview
icon: material/server-network
---

# Network Services Overview

The **Network Services** section documents the core infrastructure services that support basic network operations within the VNTD laboratory. 

These services provide fundamental functionality such as address assignment and name resolution, and are required for user endpoints and internal systems to communicate correctly across the architecture and interact with the environment.

---

## Scope

This section focuses on **infrastructure-level services** rather than application-level systems, specifically on:

- How services are architected
- How they interact with VLANs, routing, and firewall policies
- How service traffic flows across zones

Service behavior is described from a **network perspective**, not from an application or performance view.

### Available Services

<div class="grid cards" markdown>

-   :material-ip-network:{ .lg .middle } **DHCP (Dynamic Host Configuration Protocol)**

    ---

    Provides dynamic IP addressing, default gateways, and DNS settings to users across multiple VLANs.
    [Explore DHCP Design](./dhcp/design.md)

-   :material-dns:{ .lg .middle } **DNS (Domain Name System)**

    ---

    Enables hostname resolution for both internal enterprise resources and external internet simulations.
    [Explore DNS Design](./dns/design.md)

</div>

!!! info "Application services"
    Application-level services (HTTP, SSH, etc.) are documented separately.

---

## Relationship with Architecture

These services are tightly coupled with the overall architecture. While the **DHCP Server** resides in the Internal Services zone (VLAN 40) and the **DNS Server** in the DMZ (VLAN 10), they must be acccessible by the users through the central firewall.

For context on VLAN placement, routing logic, and security enforcement, refer to:

- [Architecture Overview](../architecture/index.md)
- [Traffic Flows](../architecture/traffic-flows.md)

!!! note "Application Services"
    Application-level services like HTTP, SSH, FTP, and MAIL are documented separately in the [Services section](../services/index.md).

# Network Services Overview

The **Network Services** section documents the core services that support basic network operation within the Virtual Network Threat Detection lab.

These services provide fundamental functionality such as address assignment and name resolution, and are required for user endpoints and internal systems to communicate correctly across the architecture.

## Scope of This Section

This directory focuses on **infrastructure-level network services**:

- How services are architected
- How they interact with VLANs, routing, and firewall policies
- How service traffic flows across zones

Service behavior is described from a **network perspective**, not from an application or performance view.

## Available Services

The following services are documented in this section:

- **DHCP**  
  Provides dynamic IP configuration to user across multiple VLANs.  

  [DHCP Design](./dhcp/design.md)

- **DNS**  
  Enables name resolution for internal services and external resources.  

  [DNS Design](./dns/design.md)

## Relationship with Architecture

Network services are tightly coupled with the overall architecture and traffic flows.

For context on VLAN placement, routing logic, and security enforcement, refer to:

- [Architecture Overview](../architecture/index.md)
- [Traffic Flows](../architecture/traffic-flows.md)
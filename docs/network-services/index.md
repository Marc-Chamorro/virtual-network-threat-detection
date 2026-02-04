# Network Services Overview

The **Network Services** section documents the core services that support basic network operation within the Virtual Network Threat Detection lab.

These services provide fundamental functionality such as address assignment and name resolution, and are required for user endpoints and internal systems to communicate correctly across the segmented architecture.

## Scope of This Section

This directory focuses on **infrastructure-level network services**, covering:

- How services are architected within a segmented enterprise network
- How they interact with VLANs, routing, and firewall policies
- How service traffic flows across security zones

Service behavior is described from a **network perspective**, not from an application or performance standpoint.

## Available Services

The following services are documented in this section:

- **DHCP**  
  Provides dynamic IP configuration to user endpoints across multiple VLANs.  
  The design explains how centralized address allocation is achieved using a firewall-based relay.  

  → [DHCP Design](./dhcp/design.md)

- **DNS**  
  Enables name resolution for internal services and external resources.  
  The design focuses on controlled exposure and forwarding behavior across security zones.  

  → [DNS Design](./dns/design.md)

## How to Use This Section

Each service is documented starting from its **design rationale**, followed by configuration and flow-specific documents where applicable.

It is recommended to read the **design document first** before reviewing implementation details.

## Relationship with Architecture

Network services are tightly coupled with the overall architecture and traffic flows.

For context on VLAN placement, routing logic, and security enforcement, refer to:

- [Architecture Overview](../architecture/index.md)
- [Traffic Flows](../architecture/traffic-flows.md)
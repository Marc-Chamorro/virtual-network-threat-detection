# DHCP Service Design

This document describes the **design and architecture** of the DHCP service used in the Virtual Network Threat Detection (VNTD) lab.

DHCP is a **core infrastructure service** that enables scalable client connectivity while preserving strict VLAN isolation and centralized control.

## Purpose of DHCP in the Lab

The DHCP service is responsible for:

- Dynamically assigning IP configuration to user endpoints
- Distributing network parameters consistently
- Reducing manual configuration on client nodes
- Simulating real enterprise endpoint behavior

DHCP is intentionally limited to **user-facing VLANs** and is not used for infrastructure or service nodes.

## Architectural Constraints

The DHCP design is constrained by the following architectural choices:

- VLANs are fully isolated at Layer 3
- The firewall is the default gateway for all enterprise VLANs
- User devices are located in VLAN 50 and VLAN 60
- Core services are centralized in the Internal Services VLAN (VLAN 40)

Because DHCP relies on broadcast-based discovery, a direct client–server model is not viable.

## Centralized DHCP Architecture

The lab implements a **centralized DHCP server model**, where:

- A single DHCP server runs in VLAN 40
- Multiple user VLANs are served by that server
- All DHCP traffic traverses the firewall

This approach reflects common enterprise deployments and simplifies management, logging, and policy enforcement.

## Role of the Firewall

The firewall plays a critical role in the DHCP architecture:

- Acts as default gateway for all VLANs
- Hosts the DHCP relay agent
- Enforces security policies on DHCP traffic
- Provides visibility into address assignment flows

By placing the relay on the firewall, DHCP becomes fully integrated into the network security model.

## Design Benefits

This design provides several advantages:

- **Scalability:** New user VLANs can be added without deploying new DHCP servers.
- **Security:** DHCP traffic is explicitly allowed and monitored.
- **Maintainability:** All address pools are defined in a single location.
- **Realism:** Mirrors enterprise-grade DHCP deployments.

## Relationship with Traffic Flows

The DHCP flows described here align with the **Architecture → Traffic Flows** section:

- Broadcasts originate at the client
- Relayed as unicast traffic by the firewall
- Responses follow the reverse path

Understanding this interaction is essential for debugging connectivity issues.

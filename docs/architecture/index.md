# Architecture Overview

This project implements a fully **virtualized enterprise network laboratory** designed to simulate realistic network environments and security scenarios. It uses **containers** to emulate routers, switches, firewalls, services, and users while maintaining a low resource usage. This enables advanced experimentation such as threat detection and traffic analysis on a single machine.

The architecture emphasizes **realism**, **modularity** and **isolation**, making it suitable for learning, experimentation, and security research.

## Architectural Goals

The architecture is designed to:

- Simulate a realistic enterprise network environment
- Apply network segmentation using VLANs and security zones
- Provide real network services (DNS, DHCP, Web, SSH)
- Enable traffic inspection and threat detection
- Be reproducible, extensible, and easy to modify

!!! note
    The design prioritizes *clarity* and *traceability* of traffic over extreme optimization, ensuring network behavior is clear, specific and debuggable.

## Design Philosophy

The architecture is built upon four main pillars:

1. **Isolation:** The entire laboratory runs within an isolated Docker network, ensuring that simulated attacks do not affect the host machine or any real external networks.
2. **Modularity:** Network devices (routers, firewalls, servers) are decoupled from their configurations. This allows the same container image to behave differently depending on which configuration files are attached.
3. **Observability:** All parts of the network are designed to be monitored, with dedicated zones for IDS (Intrusion Detection Systems) and centralized logging.
4. **Explicit Configuration:** All IP addresses, routing capabilities, VLANs, and service behavior are explicitly defined to avoid hidden defaults.

## Core Components

- **Orchestration:**
    - **[Containerlab](https://containerlab.dev/)** manages the creation and connection of virtual links and nodes.
    - **Docker** provides the environment for all network devices and services.
- **Network Devices:**
    - Linux-based routers using *FRRouting*.
    - A dedicated firewall container enforcing segmentation and security policy.
    - Layer 2 switches (e.g., **Arista cEOS**) implementing VLAN separation.
- **Service and Endpoint Nodes:**
    - Internal and DMZ servers providing DNS, DHCP, Web, and SSH services.
    - Client nodes simulating enterprise and external users
    - Monitoring and IDS nodes observing traffic

## Security Zones

The architecture is divided into four main functional zones:

1. **Internet Core:** Acts as the central exchange point connecting all external and internal elements.
2. **Attacker Network:** Represents external threats.
3. **Benign Network:** Represents legitimate external users interacting with enterprise services.
4. **Enterprise Infrastructure:** The core of the project, featuring a segmented architecture with a firewall, DMZ, internal services, and user floors.

## Scalability and Extensibility

Because the lab is built on Containerlab and containerized components:

- New services, devices, or entire network segments can be added by modifying the topology YAML.
- Existing images can be reused with different configurations.
- Multiple topologies can be created without changing the architecture

## Scope

- [**Network Design**](./network-design.md): Topology structure and component roles.
- [**Addressing & VLANs**](./addressing.md): IP planning and segmentation strategy.
- [**Traffic Flows**](./traffic-flows.md): Expected communication paths and control points.

# Architecture Overview

This project implements a fully **virtualized enterprise network laboratory** designed to simulate realistic network environments and security scenarios. It uses **containers** to emulate routers, switches, firewalls, services, and users while maintaining a low resource usage. This enables advanced experimentation such as threat detection and traffic analysis on a single machine.

The architecture emphasizes **realism**, **modularity** and **isolation**, making it suitable for learning, experimentation, and security research.

It closely mimics a real-world enterprise network while remaining lightweight and reproducible.

!!! warning
    This environment is **not designed for production use** and should never be exposed to real external networks.

--

## Architectural Goals

The architecture is designed to:

- Simulate a **realistic enterprise network environment**
- Apply **network segmentation** using VLANs and **security zones**
- Provide **real network services** (DNS, DHCP, Web, SSH)
- Enable **traffic inspection** and **threat detection**
- Be **reproducible**, **extensible**, and easy to **modify**

!!! info
    The design prioritizes *clarity* and *traceability* of traffic over extreme optimization, ensuring network behavior is clear, specific and debuggable.

--

## Design Philosophy

The architecture is built upon four main pillars:

1. **Isolation:** The entire laboratory runs within an isolated Docker network, ensuring that simulated attacks do not affect the host machine or any real external networks.
2. **Modularity:** Network devices (routers, firewalls, servers) are decoupled from their configurations. This allows the same container image to behave differently depending on which configuration files are attached.
3. **Observability:** All parts of the network are designed to be monitored, with dedicated zones for IDS (Intrusion Detection Systems) and centralized logging.
4. **Explicit Configuration:** All IP addresses, routing capabilities, VLANs, and service behavior are explicitly defined to avoid hidden defaults.

--

## Core Components

The laboratory is composed of the following blocks:

- **Orchestration:**
    - **Containerlab** manages the creation and connection of virtual links and nodes.
    - **Docker** provides the environment for all network devices and services.
- **Network Devices:**
    - Linux-based routers using *FRRouting*.
    - Layer 2 switches (e.g., **Arista cEOS**) implementing VLAN separation.
- **Network Security:**
    - A dedicated firewall container enforcing segmentation and security policy.
    - Custom Linux routers using NAT to communicate with the *outer world* and hiding the inner network.
- **Service and Endpoint Nodes:**
    - Internal and DMZ servers providing DNS, DHCP, Web, and SSH services.
    - Client nodes simulating enterprise and external users
    - Monitoring and IDS nodes observing traffic

--

## Security Zones

The architecture is divided into four main functional zones:

| Zone | Purpose |
|----|--------|
| **Internet Core** | Acts as the central exchange point connecting all external and internal elements |
| **Attacker Network** | Represents external threats |
| **Benign Network** | epresents legitimate external users interacting with enterprise services |
| **Enterprise Infrastructure** | The core of the project, featuring a segmented architecture with a firewall, DMZ, internal services, and user floors |

!!! note
    Each zone is isolated by routing and firewall rules to prevent unrestricted lateral movement.

--

## Scalability and Extensibility

Because the lab is built on Containerlab and containerized components:

- New services, devices, or entire network segments can be added by modifying the topology YAML.
- Existing images can be reused with different configurations.
- Multiple topologies can be created without changing the architecture

--

## Scope

- [**Network Design**](./network-design.md): Topology structure and component roles.
- [**Addressing & VLANs**](./addressing.md): IP planning and segmentation strategy.
- [**Traffic Flows**](./traffic-flows.md): Expected communication paths and control points.

---
title: Architecture Overview
icon: material/office-building
---

# Architecture Overview

This project implements a fully **virtualized enterprise network laboratory** designed to simulate realistic network environments and security scenarios. It uses **containers** to emulate routers, switches, firewalls, services, and users while maintaining a low resource usage.

The architecture emphasizes **realism**, **modularity** and **isolation**, making it suitable for learning, experimentation, and security research.

It closely mimics a real-world enterprise network while remaining lightweight and reproducible.

!!! warning "Production"
    This environment is **not designed for production use** and should never be exposed to real external networks.

---

## Architectural Goals

The architecture is designed to:

- Simulate a **realistic enterprise network environment**
- Apply **network segmentation** using VLANs and **security zones**
- Provide **real network services** (DNS, DHCP, Web, SSH)
- Enable **traffic inspection** and **threat detection**
- Be **reproducible**, **extensible**, and easy to **modify**

!!! info "Ease of Use > Optimization"
    The design prioritizes *clarity* and *traceability* of traffic over extreme optimization, ensuring network behavior is clear, specific and debuggable.

---

## Scalability and Extensibility

Because the lab is built on Containerlab and containerized components:

- New services, devices, or entire network segments can be added by modifying the topology YAML.
- Existing images can be reused with different configurations.
- Multiple topologies can be created without changing the architecture

---

## Design Philosophy

The architecture is built upon four main pillars to ensure the environment is suitable for cybersecurity research:

<div class="grid cards" markdown>

-   :material-shield-check:{ .lg .middle } **Isolation**

    ---

    The entire laboratory runs within an isolated Docker network, ensuring that simulated attacks do not affect the host machine or real external networks.

-   :material-puzzle-outline:{ .lg .middle } **Modularity**

    ---

    Network devices are decoupled from their configurations. This allows the same container image to behave differently depending on the services enabled and attached configuration files.

-   :material-eye-outline:{ .lg .middle } **Observability**

    ---

    All parts of the network are designed to be monitored, with dedicated zones for IDS and centralized logging.

-   :material-file-code-outline:{ .lg .middle } **Explicit Configuration**

    ---

    All IP addresses, routing capabilities, VLANs, and service behavior are explicitly defined in YAML and scripts to avoid hidden defaults.

</div>

---

## Security Zones

The infrastructure is logically divided into four functional zones to prevent unrestricted movement:

| Zone | Purpose |
|------|---------|
| **Internet Core** | Acts as the central exchange point connecting all external and internal elements. |
| **Attacker Network** | Represents external threats and hosts the Kali Linux node. |
| **Benign Network** | Represents legitimate external users interacting with enterprise services |
| **Enterprise Infrastructure** | The core of the project, featuring a segmented architecture with a firewall, DMZ, internal services, and user floors. |

!!! note "Enterprise Isolation"
    The enterprise zone is isolated by routing and firewall rules to prevent unrestricted lateral movement. Movement is controlled.

---

## Scope

- [**Network Design**](./network-design.md): Topology structure and component roles.
- [**Addressing & VLANs**](./addressing.md): IP planning and segmentation strategy.
- [**Traffic Flows**](./traffic-flows.md): Expected communication paths and control points.

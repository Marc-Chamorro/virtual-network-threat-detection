---
title: Docker & Containerlab Overview
icon: material/docker
---

# Docker & Containerlab Overview

The project relies on the combination of **Docker** and **Containerlab** to provide a lightweight, isolated, and fully reproducible laboratory environment. While Docker manages individual software images and containers, Containerlab serves as the manager that defines how these nodes are interconnected to form a network.

!!! tip "Evolving project"
    This documentation evolves alongside the code.
    If something outdated is spotted or can be improved, feel free to propose changes directly on GitHub.

---

## Design Philosophy

The environment is built around three core principles to ensure its utility for cybersecurity research and training:

<div class="grid cards" markdown>

-   :material-sync:{ .lg .middle } **Reproducibility**

    ---

    Every user runs the exact same software versions and configurations, eliminating inconsistencies between different host environments.

-   :material-puzzle-outline:{ .lg .middle } **Modularity**

    ---

    Images are single-purpose (e.g., router, web server, firewall) to mimic physical network devices.

-   :material-infinity:{ .lg .middle } **Persistence**

    ---

    Containers function as always-on hardware devices. They utilize specific entrypoints to remain active and keep their state intact throughout the lab session.

</div>

---

## System Integration

The collaboration between these technologies is structured as follows:

- **Docker's Role:** Provides the operating system, including the operating system layer, networking capabilities, and essential utilities (e.g., `iproute2`, `frr`, `nginx`) for each node.
- **Containerlab's Role:** Instantiates containers from these images, creates virtual network links, aand connects the topology according to the `.clab.yml` definition file.

---

## Additional Testing Topologies

In addition to the primary enterprise topology, the project includes **simplified testing environments**.

These topologies are located in the `labs/` directory:

- `V1_Testing.clab.yml`
- `V2_Testing.clab.yml`

These environments are intentionally smaller and are used for:

- Rapid testing of configuration changes.
- Debugging services without deploying the full infrastructure.
- Experimenting with simplified network scenarios

!!! note
    These testing topologies reuse the same images and configuration patterns used in the main environment but reduce the number of nodes to improve startup times.

---

## Navigation

- [**Image Catalog**](./images.md): Detailed breakdown of custom images available in the project.
- [**Dockerfile Standards**](./dockerfiles.md): Guidelines for building consistent and efficient images.
- [**Entrypoints & Behavior**](./entrypoint.md): Initialization and dynamic service management.
- [**External Images**](./supported-images.md): How to use vendor-proprietary images like Arista cEOS.

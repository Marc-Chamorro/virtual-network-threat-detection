---
title: Labs Overview
icon: material/flask-outline
---

# Labs Overview

The **Labs** module represents the core of the project's network simulation. It defines the virtual network topologies that deployed to simulate enterprise environments.

This section covers the logic behind topology definition, the orchestration process, and how individual nodes are transformed into functional network devices.

## Key Concepts

The laboratory environment is built upon three fundamental layers:

<div class="grid cards" markdown>

-   :material-file-tree:{ .lg .middle } **Topology Definition**

    ---

    The blueprint of the network, defined in YAML format. It specifies which nodes to create, their resource limits, and how to wire them together.

-   :material-cog-sync:{ .lg .middle } **Node Configuration**

    ---

    The internal logic of each device. This includes routing protocols (OSPF), security policies (iptables), and switch configurations (VLANs).

-   :material-layers-triple-outline:{ .lg .middle } **Runtime Environment**

    ---

    How Containerlab instantiates the topology using Docker.

</div>

---

## Architectural Relationship

The labs are designed to be completely modular. By changing a single configuration file or a link in the topology definition, the environment can turn from a simple connectivity test to a full enterprise infrastructure with a DMZ and multi-floor workstation segments.

!!! info "Persistence Strategy"
    To maintain reproducibility, follow a strict **configuration independence** strategy. Configurations are never stored inside the container images; they are injected at runtime using bind mounts.

---

## Navigation

- [**Topology File**](./topologies.md): A deep dive into the `*.clab.yml` structure and syntax.
- [**Lab Configuration**](./configuration.md): Detailed explanation of how routers, firewalls, and switches are configured.
- [**Available Architectures**](../architecture/index.md): Detailed breakdown of the provided environment.

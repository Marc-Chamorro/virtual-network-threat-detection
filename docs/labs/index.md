# Labs Overview

The **Labs** module is the definition of the project's topology. It defines the virtual network topologies that you will deploy to simulate enterprise environments.

This section covers the structure of the topology files, how the virtual network is architected, and how individual nodes are configured to behave like real network appliances.

## Key Concepts

- **Topology Definition:** The blueprint of the network, defined in YAML format. It specifies which nodes to create and how to wire them together.
- **Node Configuration:** The logic that runs inside each node. This includes routing protocols (OSPF), firewall rules (iptables), and switch configurations (VLANs).
- **Runtime Environment:** How Containerlab instantiates the topology using Docker.

## Navigation

- [**Topology File**](./topologies.md): A deep dive into the `*.clab.yml` structure and syntax.
- [**Lab Configuration**](./configuration.md): Explains how routers, firewalls, and switches are configured via mounted files.
- [**Available Architectures**](../architecture/index.md): Detailed breakdown of the provided environment.

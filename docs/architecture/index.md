# Architecture Overview

This project is built as a flexible system for simulating an enterprise network environment. It uses containers to simulate real networks while using minimal system resources. This makes it possible to run advanced security scenarios on a single machine.

## Design Philosophy

The architecture is built upon three main pillars:

1. **Isolation:** The entire laboratory runs within an isolated Docker network, ensuring that simulated attacks do not affect the host machine or any real external networks.
2. **Modularity:** Network devices (routers, firewalls, servers) are decoupled from their configurations. This allows the same container image to behave differently depending on which configuratino files are attached.
3. **Observability:** All parts of the network are designed to be monitored, with dedicated zones for IDS (Intrusion Detection Systems) and centralized logging.

## Core

- **Orchestration:** [Containerlab](https://containerlab.dev/) manages the creation and connection of virtual links and nodes.
- **Segmentation:** Strict VLAN separation managed by a central Firewall.
- **Observability:** Integrated IDS and monitoring servers to capture every packet entering or leaving the network.
- **Scalability:** Based on Containerlab, allowing for the cretion of new topologies or services by simply modifying the YAML definition.

## Security Zones

The architecture is divided into four main functional blocks:

1. **Internet Core:** Acts as the central exchange point connecting all external and internal elements.
2. **Attacker Network:** Represents external threats.
3. **Benign Network:** Represents legitimate external users interacting with enterprise services.
4. **Enterprise Infrastructure:** The core of the project, featuring a segmented architecture with a Firewall, DMZ, Internal Services, and User Floors.

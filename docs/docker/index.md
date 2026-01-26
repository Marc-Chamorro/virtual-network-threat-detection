# Docker Overview

This section documents the containerized infrastructure used to power the laboratory environments. The project relies on **Docker** to provide lightweight, isolated, and reproducible nodes (routers, servers, clients) that simulate a real network topology.

!!! tip
    This documentation evolves alongside the code.
    If something outdated is spotted or can be improved, feel free to propose changes directly on GitHub.

## Philosophy

The environment is designed around three core principles:

1.  **Reproducibility:** Every user runs the exact same software versions and configurations, eliminating "it works on my machine" issues.
2.  **Modularity:** Images are single-purpose (e.g., a router, a web server, a firewall) to mimic physical network appliances.
3.  **Persistence:** These containers act like always-on hardware devices. They utilize specific entrypoints to remain active (`sleep infinity`) and keep their state intact for the duration of the lab.

## Integration with Containerlab

While Docker manages the individual nodes (images and containers), **Containerlab** orchestrates the connections, links, and overall topology of the defined structure.

* **Docker's Role:** Provides the operating system, including the operating system layer, networking capabilities, and utilities (e.g., `iproute2`, `frr`, `nginx`).
* **Containerlab's Role:** Starts the containers from these images, creates the virtual network links, and connects everything based on the topology defined in the (`.clab.yml`) file.

## Quick Navigation

* [**Image Catalog**](./images.md): Detailed breakdown of every custom image available (Kali, Server, Router, etc.).
* [**Building Dockerfiles**](./dockerfiles.md): Understanding how images are constructed and the standards used.
* [**Entrypoints & Behavior**](./entrypoint.md): How containers initialize, handle startup, and manage service startups.
* [**Importing Images**](./supported-images.md): How to use vendor-proprietary images like Arista cEOS.
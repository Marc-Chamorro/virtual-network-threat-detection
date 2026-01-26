# Getting Started

This section outlines the prerequisites and requirements necessary to deploy the virtual laboratory. Ensure your system meets these criteria before proceeding to the installation.

## System Requirements

The environment is designed to be lightweight, but simulating a full enterprise topology requires moderate resources.

### Hardware

* **Architecture:** x86_64 / amd64.
* **RAM:** Minimum 12GB recommended, though XGB is preferred for full topology simulation with all monitoring services running.
* **Storage:** At least 6GB of free disk space for Docker images and an additional XGB for log data.

### Operating System
The project is built and tested on **Linux**.
- **Recommended OS:** Ubuntu 25.10.
- **Compatibility:** Most Debian-based distributions (Debian, Ubuntu, Mint) should work seamlessly.
- **Windows Users:** Native Windows is **not** supported directly. You must use **WSL2** (Windows Subsystem for Linux) (although not tested / confirmed) or a dedicated Virtual Machine (e.g., VMware, VirtualBox) running Linux.

!!! warning "Virtualization"
    It is highly recommended to install this environment inside a **Virtual Machine** or a dedicated system, completely isolated from your personal host settings and system configurations to prevent attacks from leaking into the outside world.

## Software Dependencies

The following tools are required for the installation process and environment management:

1. **Curl:** Required for downloading installation scripts and transferring data.
2. **Git:** Necessary for cloning the repository and version control.
3. **SSH Client:** Used to connect to the virtual network devices managed by Containerlab.
4. **Docker:** The core container engine.
5. **Containerlab:** The orchestration tool for the network topology.

## Deployment Strategy

The deployment follows a scripted approach:

1. **Base Setup:** Preparing the OS and installing dependencies.
2. **Image Build/Import:** Preparing the custom Docker images (Router, Server, Kali, etc.).
3. **Topology Launch:** Using Containerlab to start up the network defined in `.clab.yml`.

If you are ready to proceed, move to the [Installation](./installation.md) guide.

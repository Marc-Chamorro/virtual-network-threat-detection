---
title: Getting Started
icon: material/play-circle-outline
---

# Getting Started

Ensure your system meets these criteria before proceeding to the installation.

---

## System Requirements

The environment is designed to be lightweight, but simulating a full enterprise topology with monitoring sericves requires moderate resources.

### Hardware

* **Architecture:** x86_64 / amd64.
* **RAM:** Minimum **16GB** recommended, though higher is preferred for full AI and monitoring services running.
* **Storage:** At least 8GB of free disk space for Docker images plus additional space for log data.

### Operating System

The project is built and tested on **Linux**.

=== "Ubuntu / Debian"
    Recommended OS: **Ubuntu 22.04+** or **25.10**. This is the native environment for the automation scripts.
=== "Windows"
    Native Windows is **not** supported directly. You **must** use a dedicated Virtual Machine (VMware, VirtualBox) running Linux.
=== "macOS"
    Not officially tested. A Linux-based Virtual Machine is highly recommended for compatibility with Containerlab.

!!! warning "Virtualization Isolation"
    It is highly recommended to install this environment inside a **Virtual Machine** or a dedicated system, completely isolated from your personal host settings and system configurations to prevent attacks from leaking into the outside world.

---

## Software Dependencies

The following tools are required for the installation process and environment management:

1. **Curl:** Required for downloading installation scripts.
2. **Git:** Necessary for cloning the repository and version control.
3. **SSH Client:** Used to connect to the virtual network devices, managed by Containerlab.
4. **Docker:** The core container engine.
5. **Containerlab:** The orchestration tool for the network topology.

---

## Next Steps

If you meet the requirements, move to the [Installation Guide](./installation.md) { .md-button }

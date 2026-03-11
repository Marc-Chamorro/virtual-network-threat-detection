---
title: Getting Started
icon: material/play-circle-outline
---

# Getting Started

Ensure your system meets these criteria before proceeding to the installation.

---

## System Requirements

The environment is designed to be lightweight, but simulating a full enterprise topology with monitoring services requires moderate resources.

* **Architecture:** x86_64 / amd64.

### Minimum Requirements

| Resource | Requirement           |
|----------|-----------------------|
| CPU      | 12 cores              |
| RAM      | 20 GB                 |
| Storage  | 20 GB free disk space |

These requirements allow the complete environment to run including all the monitoring stack.

### Reduced Requirements Mode

If the **Elastic stack is disabled**, the environment can run with reduced memory:

| Resource | Requirement            |
|----------|------------------------|
| CPU      | 8–12 cores recommended |
| RAM      | 16 GB                  |
| Storage  | 20 GB                  |

In this mode the monitoring stack should be disabled.

!!! warning "Hardware Requirements"
    The monitoring stack (Suricata + Elastic components) is resource intensive.
    Long execution periods with limited resources may cause instability if system resources are insufficient.

!!! important "Monitoring Stack"
    The user can run the environment nonetheless with reduced resources. Although given that not enough resources are available, it is suggested that secondary containers are removed from the topology (e.g. benign / entire floor 2).

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

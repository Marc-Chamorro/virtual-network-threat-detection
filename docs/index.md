# Welcome to the Project Documentation

Welcome to the official documentation for the **Intelligent Threat Detection in Virtual Networks** project.

This platform is designed to deploy a **modular**, **scalable**, and fully **virtualized** cybersecurity laboratory. By simulating a segmented enterprise infrastructure, this project facilitates the generation of **real network traffic**, the execution of **simulated attacks**, and the **analysis of security logs** using Artificial Intelligence.

!!! info "Open Source"
    This project relies on **open-source** technologies such as Linux, Docker, and Containerlab to ensure accessibility and reproducibility and ease access to research on network simulation and threat detection.

[Download full documentation (PDF)](assets/pdf/vntd-docs.pdf)

---

## Project Context

This project is developed as a **Final Degree Project (Treball de Final de Grau - TFG)** for the Degree in Computer Engineering in Information Systems and Management at **TecnoCampus (Pompeu Fabra University)**.

It addresses the growing need for accessible research environments in cybersecurity. Traditional physical labs are expensive, difficult to scale and hard to reproduce. This project addresses these limitations by making use of container and network emulation technologies.

---

## Core Philosophy

The environment is built upon three pillars:

### Virtualization & Orchestration

Utilizing **Docker** and **Containerlab** to create lightweight and reproducible network nodes that represent realistic infrastructures.

### Real-World Simulation

Implementing **real services** (SSH, FTP, HTTP) and security tools (Suricata) instead of simplified or theoretical simulations to generate real traffic and logs.

### Intelligent Analysis

Integrating **Machine Learning techniques** to detect anomalies and suspicious patterns in network logs that traditional systems might miss.

---

## Documentation Structure

This documentation is organized to guide you from initial setup to advanced usage:

- [**Introduction**](./introduction.md): Detailed overview of the architecture, goals, and scope.
- [**Getting Started**](./getting-started.md): Prerequisites and requirements before installation.
- [**Installation**](./installation.md): Step-by-step guide to setting up the environment.
- [**Usage**](./usage.md): Instructions on how to run the environment and start using it.
- [**Architecture**](./architecture/index.md): Network design and traffic flows.
- [**Network Services**](./network-services/index.md): DHCP, DNS, and supporting services.
- [**Docker & Containerlab**](./docker/index.md): Images, builds, and orchestration.
- [**Labs**](./labs/index.md): Topology definitions and scenarios.
- [**Scripts & Automation**](./scripts/index.md): Management and automation tools.

---

!!! info "Project Information"
    **Author:** Marc Chamorro Mollon  
    **Tutor:** Pere Barberan Agut  
    **Academic Year:** 2025–2026  
    **License:** Open Source
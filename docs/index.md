# Welcome to the Project Documentation

Welcome to the official documentation for the **Intelligent Threat Detection in Virtual Networks** project.

This platform is designed to deploy a modular, scalable, and fully virtualized cybersecurity laboratory. By simulating a segmented enterprise infrastructure, this project facilitates the generation of real network traffic, the execution of simulated attacks, and the analysis of security logs using Artificial Intelligence.

[Download full documentation (PDF)](assets/pdf/vntd-docs.pdf)

## Project Context

This project is developed as a **Final Degree Project (Treball de Final de Grau - TFG)** for the Degree in Computer Engineering in Information Systems and Management at **TecnoCampus (Pompeu Fabra University)**.

It addresses the growing need for accessible research environments in cybersecurity. Traditional physical labs are expensive and difficult to scale. This project uses **open-source** technologies to ease access to research on network simulation and threat detection.

## Core Philosophy

The environment is built upon three pillars:

1. **Virtualization & Orchestration:** Utilizing Docker and Containerlab to create lightweight and reproducible network nodes for a realistic environment.
2. **Real-World Simulation:** Implementing actual services (SSH, FTP, HTTP) and security tools (Suricata) than simplified or theoretical simulations.
3. **Intelligent Analysis:** Integrating Machine Learning to detect anomalies in network logs that traditional systems might miss.

## Documentation Structure

This documentation is organized to guide you from initial setup to advanced usage:

- [**Introduction**](./introduction.md): Detailed overview of the architecture, goals, and scope.
- [**Getting Started**](./getting-started.md): Prerequisites and requirements before installation.
- [**Installation**](./installation.md): Step-by-step guide to setting up the environment.
- [**Usage**](./usage.md): Instructions on how to run the environment and start using it.
- **Docker & Images**: (Coming Soon) Management of the container images used in the lab.
- **Topologies**: (Coming Soon) Guide to the defined network scenarios.

!!! info "Open Source"
    This project relies on open-source technologies such as Linux, Docker, and Containerlab to ensure accessibility and reproducibility.

---

*Author: Marc Chamorro Mollon*

*Tutor: Pere Barberan Agut*

*Year: 2025-2026*
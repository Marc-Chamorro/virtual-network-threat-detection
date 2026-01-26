docs/
├── index.md                  # Landing page de la documentació
│
├── architecture/
│   ├── index.md              # Visió global de l’arquitectura
│   └── network-design.md     # Disseny de xarxa (diagrames, fluxos)
│
├── deployment/
│   ├── index.md              # Com desplegar el projecte
│   ├── requirements.md       # Requisits (Docker, containerlab, etc.)
│   └── lifecycle.md          # Deploy / destroy / reset
│
├── docker/
│   ├── index.md              # Visió general de Docker al projecte
│   ├── images.md             # Imatges custom (build / import)
│   ├── dockerfiles.md        # Estructura i bones pràctiques Dockerfile
│   ├── entrypoint.md         # Entrypoint: comportament i usos
│   └── supported-images.md   # Imatges suportades i fonts
│
├── labs/
│   ├── index.md              # Concepte de labs
│   ├── topologies.md         # Fitxers .clab.yml
│   └── configuration.md     # Configs de routers, firewalls, switches
│
├── services/
│   ├── index.md
│   ├── suricata.md
│   └── monitoring.md
│
├── scripts/
│   ├── index.md              # Automatització (run.sh, clab, images)
│   └── behaviour.md          # Decisions de disseny (ex: carpetes _*)
│
└── assets/
    └── net-design.svg

---

# Virtual Network Threat Detection

Welcome to the **Virtual Network Threat Detection** documentation.

This project provides a **container-based virtual lab** for experimenting with
network threat detection techniques using modern open-source tools.

![Network Design](assets/NET%20Design.svg)

---

## 🎯 Project Goals

- Simulate realistic network traffic
- Detect malicious activity at the network level
- Learn how IDS tools work in practice
- Keep everything reproducible using containers

---

## 🧠 What you will find here

- Architecture overview of the lab
- Network topologies used for testing
- Documentation for each security service
- Deployment and execution instructions

---

## 📦 Technologies used

| Component      | Purpose |
|----------------|--------|
| Containerlab   | Network topology orchestration |
| Suricata       | Intrusion Detection System |
| Zeek           | Network traffic analysis |
| Docker         | Container runtime |

---

!!! tip
    This documentation evolves together with the code.  
    Use the **Edit** button to propose improvements directly on GitHub.

📄 [Download full documentation (PDF)](assets/pdf/vntd-docs.pdf)

----------

# Deployment

This section explains how to deploy and run the lab environment.

---

## 🚀 Deployment Strategy

The environment is deployed using:

- Containerlab
- Docker
- Predefined topology files

---

## 📋 Prerequisites

Before starting, make sure you have:

- Docker installed
- Containerlab installed
- Sufficient system resources

---

## ▶️ Basic Workflow

```bash
git clone <repository>
cd virtual-network-threat-detection
containerlab deploy
```

---

## 🧹 Cleanup

To destroy the lab:

```bash
containerlab destroy
```

!!! important
    Always clean up resources after testing to avoid conflicts.

-------

# Architecture

This page describes the **high-level architecture** of the Virtual Network Threat Detection lab.

---

## 🏗️ Architecture Overview

The lab is composed of multiple containers connected through a virtual network.
Traffic flows through monitoring points where detection tools inspect packets.

---

## 🔁 Traffic Flow

1. Client generates traffic
2. Traffic traverses routing components
3. IDS sensors analyze packets
4. Logs and alerts are generated

---

## 🧩 Core Components

### Network Layer
- Virtual links
- Isolated subnets
- Routing elements

### Detection Layer
- Passive monitoring
- Inline inspection (optional)
- Alert generation

---

## 📐 Design Principles

- **Reproducibility**
- **Modularity**
- **Minimal manual configuration**

!!! note
    The architecture is intentionally simple to make experimentation easier.


-------

# Basic Lab Topology

This page documents the **basic topology** used as a starting point for experiments.

---

## 🧪 Purpose of this Topology

The basic lab is designed to:

- Validate connectivity
- Test IDS visibility
- Generate controlled traffic

---

## 🗺️ Topology Description

The topology consists of:

- One client node
- One server node
- One monitoring node

Traffic flows from client to server while being observed by the IDS.

---

## 🔌 Nodes Overview

| Node | Role |
|-----|------|
| Client | Generates traffic |
| Router | Forwards packets |
| Sensor | Inspects traffic |

---

## 🛠️ Usage

This topology is ideal for:

- Initial setup validation
- Rule testing
- Learning traffic inspection basics

!!! warning
    This topology is **not** meant to simulate production networks.


--------

# Suricata

Suricata is used as the **primary intrusion detection system** in this lab.

---

## 🛡️ What is Suricata?

Suricata is a high-performance IDS/IPS capable of:

- Signature-based detection
- Protocol analysis
- File extraction

---

## ⚙️ How it is used in this lab

Suricata runs as a container connected to a monitoring interface.

Key characteristics:

- Passive IDS mode
- Custom rule sets
- JSON log output

---

## 📂 Outputs

Suricata generates:

- Alerts
- Flow logs
- Statistics

```text
alert.signature
alert.severity
flow.bytes
```
!!! tip
    Start with a small rule set to avoid alert noise.
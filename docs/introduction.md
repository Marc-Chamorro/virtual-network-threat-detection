---
title: Introduction
icon: material/information-outline
---

# Introduction

The **Intelligent Threat Detection in Virtual Networks** project consists of the design and deployment of a **modular cybersecurity laboratory**. It simulates a realistic, segmented enterprise infrastructure using virtualization technologies to support **training, research, and experimentation**, enabling users to safely study attack techniques, defensive mechanisms, and traffic analysis.

---

## Purpose and Objectives

The primary objective of this project is to **generate legitimate network security data** by executing simulated attacks in a controlled environment. This data is then centralized, processed, and analyzed in real time to detect anomalies and unwanted patterns.

### Specific objectives:

- [x] **Infrastructure Simulation:** Deploying a virtual network that mimics a corporate environment, including DMZ, internal networks and administration zones.
- [x] **Threat Detection:** Implementing IDS (Intrusion Detection Systems) like **Suricata** to monitor traffic and generate logs.
- [x] **Data Analysis:** Centralizing logs (Filebeat) and applying AI algorithms (Isolation Forest) to identify security incidents.

---

## Architecture Overview

The simulation is designed to be **modular** and **scalable**. The infrastructure mimics a real enterprise network, composed of:

| Zone                    | Purpose |
| ----------------------- | --- |
| **Internet / External** | Simulates the public internet and external actors. |
| **Attacker Network**    | A dedicated segment for generating malicious traffic and executing attacks. |
| **Enterprise Network**  | The core infrastructure, protected by firewalls and segmented into DMZ, Internal, Monitoring, Users, Administration and Management zones. |

!!! warning "Safe Environment"
    This environment is **not designed for production use** and should never be exposed to real external networks. All attacks must be executed within this isolated environment.

---

## Key Features

- **Container-Based:** Built on **Docker** and **Containerlab**, ensuring the environment is lightweight and portable compared to traditional VM-based labs.
- **Integrated Services:** Nodes run **real services** (Nginx, Postfix, vsftpd) to ensure realistic traffic behavior.
- **AI-Powered:** Utilization of the **Isolation Forest** algorithm detect unusual patterns in complex log data, providing an additional layer of detection beyond fixed rules.

---

## Target Audience

This platform is intended for:

- **Students:** For practical training in a safe, isolated environment.
- **Researchers:** To experiment with new detection methodologies and dataset generation.
- **Network Administrators:** To test security configurations and topologies with limited resources.

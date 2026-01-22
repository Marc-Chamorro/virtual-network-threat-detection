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

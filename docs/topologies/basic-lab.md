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

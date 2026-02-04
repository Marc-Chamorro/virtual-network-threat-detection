# Network Design

This page describes the **logical and physical design** of the VNTD network topology, focusing on how components are interconnected and how responsibilities are distributed across the infrastructure.

## Topology Overview

The topology simulates a **multi-zone enterprise network** connected to external devices. It is built around a central Internet core and a segmented enterprise network protected by a router and a firewall.

The topology consists of:

- An Internet core router.
- Separate external networks (attacker and benign).
- An enterprise router.
- A central firewall.
- Multiple VLAN-based internal segments.

![Network Design](../assets/NET%20Design.svg)

## External Networks

### Internet Core

The `router_internet` node represents the public Internet core. It serves as the interconnection point for:

- External benign traffic.
- External attacker traffic.
- Enterprise outbound and inbound traffic.

This router uses FRRouting (FRR) to provide realistic routing behavior.

### Attacker Network

The attacker network simulates a hostile external actor:

- Dedicated router (`router_attacker`).
- A Kali Linux-based attacker node.

This network is intentionally separated to allow controlled attack generation.

### Benign Network

The benign network simulates legitimate external users:

- Dedicated router (`router_benign`).
- Lightweight client node.

This allows differentiation between malicious and legitimate traffic.

## Enterprise Core

### Enterprise Edge Router

The `router_enterprise` node connects the enterprise network to the Internet. Its responsibilities include:

- Routing between enterprise and external networks.
- Forwarding traffic towards the firewall.
- Acting as a clear limit between external and internal domains.

### Firewall

The firewall is the **central enforcement point** of the enterprise:

- Enforces inter-VLAN policies.
- Controls inbound and outbound traffic.
- Hosts DHCP relay functionality.
- Acts as the default gateway for all VLANs.

!!! important
    All enterprise VLANs are isolated by default. Inter-VLAN communication is only possible through explicit firewall rules.

## Layer 2 Segmentation

VLANs are implemented using **Arista cEOS switches**, providing realistic L2 behavior:

- Access ports for end devices.
- Trunk ports for multi-VLAN floors.
- Clear separation between zones.

Each VLAN maps to a dedicated switch instance to keep configurations readable and handleable.

## Monitoring Placement

Monitoring and IDS nodes are placed in a dedicated VLAN, ensuring:

- Visibility into enterprise traffic.
- Isolation from services and users.
- Controlled analysis tools.

Traffic mirroring and promiscuous interfaces are used where required to capture relevant packages.

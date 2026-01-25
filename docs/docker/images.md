# Image Catalog

This page provides a comprehensive documentation of the custom Docker images maintained in this project. All images are built with the `_vntd` suffix to ensure local uniqueness.

## Operating System Base Images

### Debian Slim (`debian:12-slim`)

The majority of the network nodes are built with Debian 12 Slim. This provides a stable, modern Linux environment with a small footprint, ideal for simulating general-purpose Linux routers and servers.

### Alpine Linux (`wbitt/network-multitool:alpine-extra`)

Used for lightweight testing end nodes where minimal resource consumption is critical. Used mostly for simulating user devices.

---

## Network Nodes

### Router (`router_vntd`)
A general-purpose Linux router. Unlike the official FRR image, this image is built on Debian and installs the FRR service via package managers, allowing for more system-level manipulation.

- **Base:** `debian:12-slim`
- **Key Packages:**
    - `frr`, `frr-pythontools`: For dynamic routing (OSPF, BGP).
    - `iptables`, `iproute2`: For packet manipulation and static routing.
    - `tcpdump`: For traffic capture.
- **Configuration:**
    - **IP Forwarding:** Enabled at build time by setting `net.ipv4.ip_forward=1` in `/etc/sysctl.conf`.
    - **OSPF:** Enabled at build time by setting `ospfd=yes` in `/etc/frr/daemons`.

### FRR (`frr_vntd`)

A direct import of the official FRRouting image.

- **Source:** `quay.io/frrouting/frr:10.5.0`
- **Use Case:** Pure routing between networks where realism and network tools are less critical.

!!! important
    This image does not support NAT, hence the creation of a dedicated router image.

### Firewall (`firewall_vntd`)

A dedicated node for simulating network security boundaries. Using a custom image helps it start faster, use fewer resources, and simplifies network rules management.

- **Base:** `debian:12-slim`
- **Key Packages:**
    - `iptables`: The core packet filtering tool.
    - `conntrack`: Enables stateful inspection capabilities.
    - `bridge-utils`: For transparent bridging scenarios.
- **Startup Behavior:**
    - Flushes all existing `iptables` rules (NAT, Mangle, Filter) on boot.
    - Enables IP Forwarding.
    - Sets default policies (INPUT/FORWARD DROP, OUTPUT ACCEPT) 

### MLS (`mls_vntd`)

!!! note
    This directory starts with `_` and is currently ignored by build scripts.

Intended to simulate a Multi-Layer Switch.

- **Key Packages:** `bridge-utils` (brctl).
- **Behavior:** Cleans network tables and enables forwarding.

---

## Service Nodes

### Server (`server_vntd`)

An image designed to simulate an endpoint server providing various network services. Features can be toggled via environment variables.

- **Base:** `debian:12-slim`
- **Services Included:**
    - **SSH:** `openssh-server` (Configured to allow password auth).
    - **Web:** `nginx`.
    - **DHCP:** `isc-dhcp-server`.
- **Environment Variables:**
    You can control this container using the following variables in your topology file:
    - `SSH_SERVER=1`: Starts the SSH daemon. Creates user `vntd` with password `pswd`.
    - `WEB_SERVER=1`: Starts Nginx and serves a default HTML page.
    - `ENABLE_DHCP=1`: (Commented out in source) Intended to start the DHCP service.

### Monitoring (`monitoring_vntd`)

A management station based on Ubuntu, designed for network package processing.

- **Base:** `ubuntu:22.04`
- **Key Packages:** `git`, `nmap`, `tcpdump`, `curl`.

---

## Security & Pentesting

### Kali (`kali_vntd`)

A simulation of an attacker machine.

- **Base:** `kalilinux/kali-rolling`
- **Key Packages:**
    - `nmap`: Port scanning.
    - `openssh-client`: Remote connectivity.
    - Standard network tools: `iproute2`, `net-tools`, `curl`.

### IDS (`ids_vntd`)

Intrusion Detection System node.

- **Base:** `debian:12-slim`
- **Key Packages:** `tcpdump`, `iproute2`.
- **Use Case:** Passive traffic analysis and logging.
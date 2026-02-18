---
title: Image Catalog
icon: material/format-list-bulleted
---

# Image Catalog

All custom images developed for this project are built with the **`_vntd`** suffix to ensure they remain unique within the local Docker registry and prevent naming conflicts.

---

## Operating System Base Images

The project utilizes two primary base environments configured for either robust infrastructure services or lightweight user endpoints.

=== "Debian Slim" 
    - **Image Identifier:** **`debian:12-slim`**
    - **Usage:** Serves as the foundation for most infrastructure nodes, including routers, firewalls, and servers. 
    - **Characteristics:** Selected for its stability, modern Linux environment with a small footprint, and minimal storage footprint, making it ideal for simulating general-purpose Linux routers and servers.

=== "Alpine Linux"
    - **Image Identifier:** **`alpine_vntd`** (based on `wbitt/network-multitool:alpine-extra`)
    - **Usage:** Simulates user workstations and lightweight end-nodes.
    - **Technical Detail:**
        - **`dhcpcd`:** Allows users to receive IP address automatically. Relies on the startup script, so the machine waits for the DHCP server to start and offer an address. Otherwise, it believes no DHCP server is available and stops asking.
        - **`lftp`:** Client FTP service.
        - **`mutt`:** Mail User Agent. Binds a configuration file for a specific user so that each machine has an already included profile and no manual action is needed. Relies on the startup script, to create a couple of mandatory directories.
    - **Environment Variables:** You can control this container using the following variables in your topology file *(these attributes are not applied on the `entrypoint`, but rather on the `startup` file)*:
        - `DHCP_CLIENT=1`: Starts the DHCP client service daemon, which makes it so that it doesn't stop asking for an address until one is assigned.
            - `IFACE="eth1"`: Define the interface used on the device. If none is assigned, it'll use `eth1` by default.
        - `MUTT_CLIENT=1`: Starts the `mutt` client configuration process. Requires a user configuration file to be assigned.

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

---

### FRR (`frr_vntd`)

A direct import of the official FRRouting image.

- **Source:** `quay.io/frrouting/frr:10.5.0`
- **Use Case:** Pure routing between networks where realism and network tools are less critical.

!!! important
    This image does not support NAT; hence the creation of a dedicated router image.

---

### Firewall (`firewall_vntd`)

A dedicated node for simulating network security boundaries. Using a custom image helps it start faster, use fewer resources, and simplifies network rules management.

- **Base:** `debian:12-slim`
- **Key Packages:**
    - `iptables`: The core packet filtering tool.
    - `conntrack`: Enables stateful inspection capabilities.
    - `bridge-utils`: For transparent bridging scenarios.
    - `isc-dhcp-relay`: Relaying DHCP traffic between clients and the DHCP server.
- **Startup Behavior:**
    - Flushes all existing `iptables` rules (NAT, Mangle, Filter) on boot.
    - Enables IP Forwarding.
    - Sets default policies (INPUT/FORWARD DROP, OUTPUT ACCEPT) 
- **Environment Variables:**
    You can control this container using the following variables in your topology file:
    - `DHCP_RELAY=1`: Starts the DHCP relay service (configuration files are required to make this service work).

---

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
    - **SSH:** `openssh-server` (Configured to allow password authentication).
    - **Web:** `nginx`.
    - **DHCP:** `isc-dhcp-server`.
    - **DNS:** `dnsmasq`.
    - **FPT:** `vsftpd`.
    - **MAIL:** `postfix`, `dovecot-core`, `dovecot-imapd`.
- **Environment Variables:**
    You can control this container using the following variables in your topology file:
    - `SSH_SERVER=1`: Starts the SSH daemon. Creates user `vntd` with password `pswd`.
    - `WEB_SERVER=1`: Starts Nginx and serves a default HTML page.
    - `DHCP_SERVER=1`: Intended to start the DHCP service (configuration files are required to make this service work (2)). Requires the following variables to be configured for the service to properly work (used for the system to wait for the parameters before starting the server; if not, the service would crash).
        - `IFACE: "eth1"`: Define the interface used on the device.
        - `IP_ADDR: "192.168.40.10"`: Define the IP address to be assigned to the interface.
    - `DNS_SERVER=1`: Start the DNS service (configuration files are required to make this service work).
    - `FTP_SERVER=1`: Intended to start the FTP service (configuration files are required to make this service work (2)).
    - `MAIL_SERVER=1 || MAIN_MAIL_SERVER=1`: Starts the mail server as a secondary or primary mail provider (requires multiple configuration files (3)).

---

### Monitoring (`monitoring_vntd`)

A management station based on Ubuntu, designed for network packet processing.

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

---

### IDS (`ids_vntd`)

Intrusion Detection System node.

- **Base:** `debian:12-slim`
- **Key Packages:** `tcpdump`, `iproute2`.
- **Use Case:** Passive traffic analysis and logging.

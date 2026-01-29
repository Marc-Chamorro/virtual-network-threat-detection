# Lab Configuration Guidelines

While the topology file defines the *structure* of the network, the behavior of the individual nodes is determined by their configuration files. In this project, we decouple configuration from the container images to allow for quick response and flexibility.

This document outlines how to configure the different types of nodes available in the environment, using the provided Docker images as a baseline.

## 1. Linux Routers (FRRouting / Custom Image)

Nodes using the `frr_vntd` or `router_vntd` images are powered by either **FRRouting (FRR)** or a custom image with routing services installed. Configuration is managed via file mounts rather than interacting with the shell manually.

### Required Files

- **`/etc/frr/daemons`**: Controls which routing protocols are enabled. You must explicitly set these up like `ospfd=yes` or `bgpd=yes`.
- **`/etc/frr/frr.conf`**: The configuration file containing interface IP addresses, routing policies, and protocol definitions.

### Best Practices

- Mount a centralized `daemons` file if all routers use the same protocols.
- Keep separate `frr.conf` files for each router in your `config/` directory (e.g., `config/router/internet/frr.conf`).

---

## 2. Linux Firewalls & Servers (Custom Images)

Generic Linux nodes (Debian, Alpine) often require more advanced setup sequences to give a dedicated image the designated capabilities (e.g., setting up `iptables`, creating bridges, or starting services).

### The Startup Script Pattern

Instead of hardcoding commands in the `exec` section of the topology file, we use a `startup.sh` scripts mounted to the container.

**Topology Definition:**

```yaml
firewall:
  kind: linux
  image: firewall_vntd:latest
  binds:
    - ./config/firewall/my-lab/startup.sh:/startup.sh
  exec:
    - sh /startup.sh
```

### What goes in `startup.sh`?

- **IP Addressing:** `ip addr add ...`
- **Interface Management:** Creating bridges (`ip link add type bridge`) or VLAN sub-interfaces (`ip link add link eth0 name eth0.10 type vlan id 10`).
- **System Toggles:** Enabling IP forwarding (`sysctl -w net.ipv4.ip_forward=1`).
- **Security Rules:** Defining `iptables` or `nftables` policies.

## 3. Arista cEOS Switches

Arista cEOS (Containerized EOS) nodes emulate enterprise-grade switching. They consume standard EOS CLI configuration files.

!!! danger
    Arista cEOS switches do not support assigning access lists to either VLANs orports. This means such switches cannot be used as a Multi Layer Switch (L3). Hence, the provided `_mls` images.

### Configuration Injection

Containerlab supports a native `startup-config` parameter for Arista nodes. This applies the configuration immediately upon boot.

### Topology Definition:

```yaml
switch_access:
  kind: arista_ceos
  image: ceos_vntd:latest
  startup-config: ./config/switch/access_layer.cli
```

### Configuration File (`.cli`)

The file should contain standard Arista CLI commands.

```
hostname switch-access
!
vlan 10
   name Chosen_Name
!
interface Ethernet1
   switchport mode access
   switchport access vlan 10
!
```

## 4. Configuration Persistence Strategy

To ensure your lab remains reproducible and easy to manage, follow these guidelines:

1. **Do not modify containers manually:** Avoid running `docker exec` to change configurations interactively, as these changes are lost when the lab is destroyed.

2. **Use the `config/` directory:** Store all `frr.conf`, `startup.sh`, and `.cli` files in a structured directory tree within your project (e.g., `config/<node_type>/<location_node>/`).

3. **Bind Mounts:** Always map the local files to the expected paths inside the container using the `binds` section of the topology file.

By following this pattern, you can switch between completely different network behaviors (e.g., OSPF vs. BGP) simply by changing the mount paths in your topology file, without rebuilding the Docker image.

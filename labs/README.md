<a id="readme-top"></a>

# Labs Directory

This directory contains all **Containerlab topology definitions** used in the prject.

Each topology is described by a `*.clab.yml` file and can be deployed independently using the provided management scripts.

## Table of Contents

- [Considerations](#considerations)
- [Directory Contents]
- [Topology Definition Files]
- [Provided Topology]
- [Notes and Extensibility]
- [References]

## Considerations

Although the objective of such environment is to simulate a real-life environment and enterprise network, some simplifications have been applied to ensure the environment is lighter in terms of computing capabilities. For such, some connections / configurations are not fully realistic, to avoid non-relevant settings.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Directory Contents

```
topology.clab.yml
clab-virtual-env/
config/
├─ router/
├─ mls/
└─ switch/
```

The `topology.clab.yml` represents the project's topology.

These directories are:
- `clab-virtual-env`: Automatically created directory created by Containerlab to keep al the necessary files that are needed to run/configure the nodes.
- `config/`: Configuration files for the network devices which are mounted into containers at runtime. This helps:
    - Keep clean the topology definitions and readable.
    - Allows reuse of configurations across multiple labs.
    - Enables changing the devices configurations without rebuilding the images.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Topology Definition Files

Each `*.clab.yml` file defines a **complete virtual network topology**, including:
- Network nodes (routers, switches, hosts, firewalls).
- Docker images used by each node.
- Interface management and routing.
- Startup commands and configurations.
- Physical and logical links between nodes.

Multiple topology files can exist in this directory. Each one represents a separate lab scenario that can be deployed individually.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Provided Topology

The provided topology simulates a **multi-zone enterprise network** with external connectivity.

![Topology Image](../images/NET%20Design.svg)

### Architecture

The topology is divided into four main network zones:
1. Internet Zone
2. Attacker Network
3. Benign Network
4. Enterprise Network

All zones interconnect through an Internet router, allowing realistic routing, NAT, and traffic flow between internal and external networks.

### Network Zones

#### 1. Internet Zone

**Components:**
- `router_internet`: FRR-based router
- `internet_server`: Alpine Linux host

**Purpose:**
- Acts as the central routing hub.
- Provides outside connectivity for all other networks.
- Simulates an external Internet environment.

IP forwarding is enabled on the router, and FRR handles routing between zones.

#### 2. Attacker Network

**Components:**
- `router_attacker`: FRR-based router
- `attacker`: Kali Linux

**Purpose:**
- Simulates a hostile external network.
- Allows generation of malicious traffic toward the enterprise.

The attacker host routes all traffic thorugh its local router, which then connects to the Internet router.

#### 3. Benign Network

**Components:**
- `router_benign`: FRR-based router
- `benign`: Alpine Linux

**Purpose:**
- Simulates a legitimate external user.
- Generates normal, non-malicious traffic.

This network mirrors the attacker setup but represents trusted sources.

#### 4. Enterprise Network

**Components:**
- `router_enterprise`: Debian Slim
- `multilayer_switch`: Arista cEOS
- `switch_vlanXX`: Arista cEOS
- `pc_vlanXX`: Alpine Linux host

**Purpose:**
- Represents a segmented enterprise LAN.
- Uses VLANs to separate internal networks.
- Routes traffic through a perimeter router with NAT.

The enterprise multilayer switch:
- Performs routing between VLANs.

The enterprise router:
- Performs routing to external networks.
- Applies NAT for outgoing traffic.
- Uses FRR to manage outside network traffic.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes and Extensibility

- Additional topologies can be added by creating new `*.clab.yml` files.
- Different network OSes can be used interchangeably.
- The topology is designed to be extended and or replaced.

Official Containerlab examples are provided on the web site to experiment and expand knowledge.

Some images can not be imported into containerlab, as many product are shipped only in virtual machine packaging. Such machines can be used in Containerlab but require additional steps such as:
- Obtaining the image manually
- Obtain the `vrnetlab` package
- Follow the instructions provided for the specified image

In detail steps to manage such machines can be found at: [VM based routers integration](https://containerlab.dev/manual/vrnetlab/)

And the Git repository in charge of packaging VMs into containers can be found at: [vrnetlab](https://github.com/srl-labs/vrnetlab)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## References

Some additional resoruces that may help:

- Topology definition: [Containerlab](https://containerlab.dev/manual/topo-def-file/)

- Official Examples: [Containerlab](https://containerlab.dev/lab-examples/lab-examples/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>
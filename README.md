<a id="readme-top"></a>

<br />
<div align="center">

  <h3 align="center">Intelligent Threat Detection in Virtual Networks Using Containerlab and AI</h3>

  <p align="center">
    <strong>Final Degree Project (Treball de Fi de Grau)</strong>
    <br />
    Degree in Computer Engineering in Management and Information Systems
    <br />
    TecnoCampus, affiliated with Pompeu Fabra University
    <br />
    <br />
    <a href="https://marc-chamorro.github.io/virtual-network-threat-detection/"><strong>Explore the Full Docs »</strong></a>
    <br />
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about">About</a></li>
    <li>
      <a href="#project-pillars">Project Pillars</a>
      <ul>
        <li><a href="#infrastructure-design">Infrastructure Design</a></li>
        <li><a href="#real-service-implementation">Real Service Implementation</a></li>
        <li><a href="#network-monitoring">Network Monitoring</a></li>
        <li><a href="#under-dev-intelligent-threat-detection-ai">[UNDER DEV] Intelligent Threat Detection (AI)</a></li>
      </ul>
    </li>
    <li><a href="#project-structure">Project Structure</a></li>
      <ul>
        <li><a href="#key-components">Key Components</a></li>
      </ul>
    <li><a href="#getting-started">Getting Started</a></li>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#quick-installation">Quick Installation</a></li>
        <li><a href="#execution">Execution</a></li>
        <li><a href="#typical-workflow">Typical Workflow</a></li>
        <li><a href="#available-architecture">Available Architecture</a></li>
      </ul>
    <li><a href="#monitoring">Monitorin</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

---

# About

This repository contains the implementation developed as part of a **Final Degree Project (TFG)**.  
The objective of the project is to **provide a modular and scalable virtualized laboratory environment to simulate enterprise network infrastructures for cybersecurity research**.

The main goal of this project is to connect network simulation with smart security analysis. By using **Containerlab** and **Docker**, the system lets users:

- Simulate complex, segmented enterprise networks.
- Generate both legitimate and malicious traffic in a safe, isolated environment.
- Monitor network traffic with professional IDS tools like **Suricata**.
- Centralize and analyze logs with **Elastic tools** and **Machine Learning** to find unusual activity and threats.

This repository is designed to be reproducible and generate real security data through simulated attacks. Allowing students and researchers to deploy a complete security lab with a single command in minutes.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Project Pillars

## Infrastructure Design

The environment uses **Containerlab** and **Docker** to simulate a realistic, segmented enterprise network.

- **Security Zones:** The architecture is divided into four main zones:
  - Internet Core
  - Attacker Network
  - Benign Network
  - Enterprise Infrastructure
- **L2/L3 Segmentation:** Internal organization is managed with VLANs (DMZ, Monitoritng, Admin, Services, and Users) using Arista cEOS switches and a central Linux-based firewall.
- **Isolation:** The entire lab runs within an isolated Docker network to ensure simulations do not affect the host machine or ouside networks.

## Real Service Implementation

This lab implements real services to generate authentic network behavior and realistic logs in comparison to other theoretical models.

- **Web & Management:** Nginx HTTP server and OpenSSH server.
- **Infrastructure:** Centralized DHCP (ISC) and DNS (Dnsmasq) providing dynamic configuration to nodes.
- **Enterprise Workloads:** A complete Mail stack (Postfix/Dovecot) for SMTP/IMAP simulations and an FTP server (vsftpd) with chroot isolation.

## Network Monitoring

Security visibility is provided by a dedicated Intrusion Detection System (IDS) node.

- **Traffic Mirroring:** The central firewall uses the TEE function in iptables to clone all inbound/outbound packets from the enterprise network and send them to the IDS node.
- **Log Generation:** Suricata monitors mirrored traffic in promiscuous mode, generating JSON-formatted logs for real-time analysis of simulated threats like Port Scanning or DoS attacks.
- **Data Sorting and Structuring:** Elastic tools recover the records created by Suricata, store them internally structurally and provide resources to analyze such data through dashboards and analytics.

## [UNDER DEV] Intelligent Threat Detection (AI)

The final stage of the project involves processing security data using Machine Learning.

#### MAY BE SUBJECTED TO CHANGES
- **Model:** Implementation of the **Isolation Forest** algorithm for anomaly detection.
#### MAY BE SUBJECTED TO CHANGES
- **Objective:** Detect unusual patterns in complex logs that traditional systems might overlook.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Project Structure

```
.
├─ docker/
│  ├─ build/
│  └─ import/
├─ docs/
├─ labs/
│  ├─ config/
│  └─ *.clab.yml
├─ scripts/
├─ run.sh
└─ README.md
```

## Key Components

- `docker/`: Contains the source code for the nodes (Routers, Kali, Servers, etc.).
  - `build/`: Contains the custom nodes source code.
  - `import/`: Import external images (.tar.xz).
- `docs/`: Documentation source files, also available published at: [Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/).
- `labs/`: Topology design and configuration files for the network device services and configurations.
  - `config/`: Persistent node configurations.
  - `*.clab.yml`: Containerlab network topology blueprints.
- `scripts/`: Internal logic used by the environment for building and lab management.
- `run.sh`: Main entry point for executing, building and deploying the laboratory.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Getting Started

## Prerequisites

- **OS:** Linux (Ubuntu 22.04+ recommended).
- **Hardware:** 
  - **Base Lab:** 12GB RAM and 8 CPU cores.
  - **Full Monitoring:** 20GB RAM and 12 CPU cores (required for the ELK Stack).
- **Tools:** Docker and Containerlab must be fully installed.

**Recommendation**
- Use a dedicated VM to ensure no malicious traffic or content accidentally spreads to any sensitive device.

For detailed requirements, see: [Docs - GettingStarted](https://marc-chamorro.github.io/virtual-network-threat-detection/getting-started/)

## Quick Installation

1. **Install Core Tools:** Follow the [Docs - Installation](https://marc-chamorro.github.io/virtual-network-threat-detection/installation/) to set up Docker and Containerlab.

2. **Clone the Repo:**
```bash
git clone https://github.com/marc-chamorro/virtual-network-threat-detection.git
cd virtual-network-threat-detection
chmod +x run.sh
```

## Execution

The project is managed via the `run.sh` interactive menu.

```bash
sudo ./run.sh
```

*Use the interactive menu to firstly build images (Image Control) and then deploy the scenario (Topology Control).*

***Mandatory import***

It is necessary to import external images into the laboratory for it to work propperly. Follow the steps available at: [Docs - External Images](https://marc-chamorro.github.io/virtual-network-threat-detection/docker/supported-images/?h=arista#arista-ceos)

## Typical Workflow

1. **Build & Import Images:** Use the image control menu to build project images (`*_vntd`) and import mandatory vendor images like Arista cEOS.
2. **Deploy Topology:** Select `topology.clab.yml` from the Topology Control menu.
3. **Analyze:** Once the network is up, traffic is automatically monitored by the IDS nodes. It may tak some minutes to fully boot the Elastic tools.

For a full walkthrough of the script options, see the [Docs - Usage Guide](https://marc-chamorro.github.io/virtual-network-threat-detection/usage/).

## Available Architecture

All the vaialable topologies provided can be found at:

```
labs/
```

The primary scenario presented is an **Enterprise Network** segmented and distributed across multiple zones:
- **Internet Zone:** Simulates the Internet and publicly available services.
- **Attacker Network:** A hostile segment featuring Kali Linux for threat generation.
- **Benign Network:** A peaceful segment used to generate legitimate traffic.
- **Enterprise Infrastructure:** Segmented into specific functional VLANs:
  - **DMZ (VLAN 10):** Public-facing services (Web, Mail).
  - **Monitoring (VLAN 20):** Dedicated segment for IDS and log management.
  - **Administrators, Users & Internal:** Zones for administrative control, end-user devices, and internal services such as DHCP and FTP.

**Enterprise Main Lab:** named `topology.clab.yml`, is the core environment used for the TFG research.

![Example Topology](docs/assets/NET%20Design.svg)

Additional topologies can be added by following the guidelines described in the topology documentation [Docs - Labs Overview](https://marc-chamorro.github.io/virtual-network-threat-detection/labs/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Monitoring

The infrastructure includes a dedicated Logwatch node that centralizes network logs for further analysis. This node makes use of the tools:

- **Suricata:** *Detection* - Network intrusion detection service that analyzes traffic and generates logs.
- **Filebeat:** *Ingestion* - Log shipper that collects and forwards events and logs from Suricata to Elasticsearch.
- **Elasticsearch:** *Indexing* - Search and analytics engine that indexes and stores the collected data.
- **Kibana:** *Visualization* - Web interface to explore, analyze and visualize data stored in Elasticsearch.

The data can be viewed directly for the host machine using the Containerlab provided address. For more information, see [Docs - Monitoring - Kibana](https://marc-chamorro.github.io/virtual-network-threat-detection/monitoring/kibana/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# License

This project is developed as part of an academic Final Degree Project. See `LICENSE` for more information.

Distributed under the **GNU GPLv3 License**. This project is developed for academic and research purposes as part of a Final Degree Project. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

>**Author:** Marc Chamorro Mollon | **Tutor:** Pere Barberan Agut | **Year:** 2025–2026
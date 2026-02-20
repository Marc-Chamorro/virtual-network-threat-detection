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
      <a href="#project-pilars">Project Pilars</a>
      <ul>
        <li><a href="#infrastructure_design">Infrastructure Design</a></li>
        <li><a href="#real_service_implementation">Real Service Implementation</a></li>
        <li><a href="#network_monitoring">Network Monitoring</a></li>
        <li><a href="#intelligent_analysis">Intelligent Analysis</a></li>
      </ul>
    </li>
    <li><a href="#project_structure">Project Structure</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

---

# About

This repository contains the implementation developed as part of a **Final Degree Project (TFG)**.  
The objective of the project is to **provide a modular and scalable virtualized environment to simulate enterprise network infrastructures for cybersecurity research**.

The main goal of this project is to connect network simulation with smart security analysis. By using Containerlab and Docker, the system lets users:

- Simulate complex, segmented networks.
- Generate both normal and malicious traffic in a safe, isolated environment.
- Monitor network traffic with real IDS tools like Suricata.
- Analyze logs with Elastic tools and Machine Learning (Isolation Forest) to find unusual activity and threats.

This repository is designed to be reproducible, allowing students and researchers to deploy a complete security lab with a single command.

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

#### THIS CONTENT IS BEING BUILT, MAY BE SUBJECTED TO CHANGES
- **Log Generation:** Suricata monitors mirrored traffic in promiscuous mode, generating JSON-formatted logs for real-time analysis of simulated threats like Port Scanning or DoS attacks.

- **Data Sorting and Structuring:** -> Elastic (wait just in case elastic fails or smtg)

## Intelligent Threat Detection (AI)

The final stage of the project involves processing security data using Machine Learning.

#### MAY BE SUBJECTED TO CHANGES
- **Model:** Implementation of the **Isolation Forest** algorithm for anomaly detection.
- **Objective:** Detect unusual patterns in complex logs that traditional systems might overlook.

# Project Structure

```
.
├─ docker/
│  └─ ...
├─ docs/
│  └─ ...
├─ labs/
│  └─ ...
├─ scripts/
│  └─ ...
├─ run.sh
└─ README.md
```

### Key Components

- `run.sh`: Main entry point for executing, building and deploying the lab.
- `docker/`: Contains the source code for the custom nodes (Routers, Kali, Servers, etc.).
- `docs/`: Documentation files, also available published at: [Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/).
- `labs/`: Contains the topology design and configuration files for individual network devices.
- `scripts/`: Internal logic used by the environment for building and lab management.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Getting Started

## Prerequisites

- **OS:** Linux (Ubuntu 22.04+ or 25.10 recommended).
- **Hardware:** At least 12GB of RAM and 8 cores are required to run the designed environment, XXXXXXXXX with the monitoring tools.
- **Tools:** Docker and Containerlab fully installed.

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
./run.sh
```

*Use the interactive menu to firstly build images (Image Control) and then deploy the scenario (Topology Control).*

***Mandatory import***

It is necessary to import external images into the laboratory for it to work propperly. Follow the steps available at: [Docs - External Images](https://marc-chamorro.github.io/virtual-network-threat-detection/docker/supported-images/?h=arista#arista-ceos)

## Typical Workflow:

1. **Image Control:** Build your project images (*_vntd) and import external images.
2. **Topology Control:** Select a lab from the labs/ directory and deploy it.
3. **Analyze:** Once the network is up, traffic is automatically monitored by the IDS nodes.

For a full walkthrough of the script options, see the [Docs - Usage Guide](https://marc-chamorro.github.io/virtual-network-threat-detection/usage/).

## Available Topology

Allthe vaialable topologies provided can be found at:

```
labs/
```

The primary scenario provided is an **Enterprise Network** featuring multiple zones.

**Enterprise Main Lab:** named `topology.clab.yml`, is the core environment used for the TFG research.

![Example Topology](images/NET%20Design.svg)

Additional topologies can be added by following the guidelines described in the topology documentation [Docs - Labs Overview](https://marc-chamorro.github.io/virtual-network-threat-detection/labs/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# License

This project is developed as part of an academic Final Degree Project. See `LICENSE` for more information.

Distributed under the **GNU GPLv3 License**. This project is developed for academic and research purposes as part of a Final Degree Project. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

>**Author:** Marc Chamorro Mollon | **Tutor:** Pere Barberan Agut | **Year:** 2025–2026
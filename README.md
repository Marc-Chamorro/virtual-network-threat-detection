<a id="readme-top"></a>

<br />
<div align="center">
  <h1 align="center">Intelligent Threat Detection in Virtual Networks</h1>
  <h3 align="center">Using Containerlab, Docker and Machine Learning</h3>
  <p align="center">
    <strong>Final Degree Project (Treball de Fi de Grau)</strong>
    <br />
    Degree in Computer Engineering in Management and Information Systems
    <br />
    TecnoCampus, affiliated with Pompeu Fabra University
    <br />
    <br />
    <img src="https://img.shields.io/badge/Containerlab-Topology-blue?style=flat-square&logo=docker" />
    <img src="https://img.shields.io/badge/Suricata-IDS-orange?style=flat-square" />
    <img src="https://img.shields.io/badge/Isolation%20Forest-Anomaly%20Detection-green?style=flat-square&logo=python" />
    <img src="https://img.shields.io/badge/ELK-Stack-005571?style=flat-square&logo=elastic" />
    <img src="https://img.shields.io/badge/License-GPLv3-lightgrey?style=flat-square" />
    <br />
    <br />
    <a href="https://marc-chamorro.github.io/virtual-network-threat-detection/"><strong>Explore the Full Docs »</strong></a>
  </p>
</div>

---

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
        <li><a href="#intelligent-threat-detection-ai">Intelligent Threat Detection (AI)</a></li>
      </ul>
    </li>
    <li>
      <a href="#project-structure">Project Structure</a>
      <ul>
        <li><a href="#key-components">Key Components</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#quick-installation">Quick Installation</a></li>
        <li><a href="#execution">Execution</a></li>
        <li><a href="#typical-workflow">Typical Workflow</a></li>
        <li><a href="#available-architecture">Available Architecture</a></li>
      </ul>
    </li>
    <li><a href="#monitoring">Monitoring</a></li>
    <li><a href="#license">License</a></li>
  </ol>
</details>

---

# About

This repository contains the implementation developed as part of a **Final Degree Project (TFG)**.  
The objective is to **provide a modular and scalable virtualized laboratory environment to simulate enterprise network infrastructures for cybersecurity research**.

The main goal is to connect network simulation with smart security analysis. By using **Containerlab** and **Docker**, the system lets users:

- Simulate complex, segmented enterprise networks.
- Generate both legitimate and malicious traffic in a safe, isolated environment.
- Monitor network traffic with professional IDS tools like **Suricata**.
- Centralize and analyze logs with **Elastic tools**.
- Detect anomalies in real time using a trained **Machine Learning** model.

This repository is designed to be reproducible and generate real security data through simulated attacks. Allowing students and researchers to deploy a complete security lab with a single command in minutes.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

# Project Pillars

## Infrastructure Design

The environment uses **Containerlab** and **Docker** to simulate a realistic, segmented enterprise network.

- **Security Zones:** The architecture is divided into four main zones:
  - Internet Core
  - Attacker Network
  - Benign Network
  - Enterprise Infrastructure
- **L2/L3 Segmentation:** Internal organization is managed with VLANs (DMZ, Monitoring, Admin, Services, and Users) using Arista cEOS switches and a central Linux-based firewall.
- **Isolation:** The entire lab runs within an isolated Docker network to ensure simulations do not affect the host machine or outside networks.

## Real Service Implementation

This lab implements real services to generate authentic network behaviour and realistic logs.

- **Web & Management:** Nginx HTTP server and OpenSSH server.
- **Infrastructure:** Centralized DHCP (ISC) and DNS (Dnsmasq) providing dynamic configuration to all nodes.
- **Enterprise Workloads:** A complete mail stack (Postfix/Dovecot) for SMTP/IMAP simulations and an FTP server (vsftpd) with chroot isolation.

## Network Monitoring

Security visibility is provided by a dedicated Logwatch node that centralizes all network logs.

- **Traffic Mirroring:** The central firewall uses the TEE function in `iptables` to clone all inbound/outbound packets from the enterprise network and forward them to the IDS node.
- **Log Generation:** Suricata monitors mirrored traffic in promiscuous mode, generating JSON-formatted logs for real-time analysis of threats like port scanning or DoS attacks.
- **Data Sorting and Structuring:** Elastic tools collect the records created by Suricata, store them structurally, and provide dashboards and analytics to visualize and investigate events.

## Intelligent Threat Detection (AI)

The final stage of the project processes security data using **Machine Learning** to detect anomalies that rule-based systems may miss.

- **Algorithm:** [Isolation Forest](https://marc-chamorro.github.io/virtual-network-threat-detection/ml/), an unsupervised anomaly detection model trained exclusively on benign Suricata traffic.
- **Features:** 26 features extracted from Suricata `eve.json` logs, including TCP flags, flow statistics, port information, and time-window counters.
- **Real-Time Detection:** A terminal-based detector (`detect.py`) reads live Suricata logs from the `logwatch` container and scores each event against the trained model.
- **Pre-Trained Model Included:** A ready-to-use model is bundled in `ml/models/`, no retraining required to get started.
- **Jupyter Notebook:** A full training pipeline is provided in `ml/notebooks/VNTD_ML.ipynb` for experimentation and retraining.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

# Project Structure

```
.
├── docker/
│   ├── build/                  # Custom node Dockerfiles
│   └── import/                 # External vendor images (.tar.xz)
├── docs/                       # Documentation source files (MkDocs)
├── labs/
│   ├── config/                 # Persistent node configurations
│   └── *.clab.yml              # Containerlab topology blueprints
├── ml/
│   ├── data/                   # Training and evaluation datasets (Git LFS)
│   ├── models/                 # Trained model artefacts (Git LFS)
│   ├── notebooks/              # Jupyter training pipeline
│   ├── realtime/               # Real-time detector source code
│   └── requirements.txt        # Python dependencies
├── scripts/
│   ├── attacks/                # Attack simulation scripts
│   ├── clab/                   # Containerlab management scripts
│   ├── images/                 # Docker image build & import scripts
│   └── ml/                     # ML detector launch scripts
├── run.sh                      # Main entry point
└── README.md
```

## Key Components

- **`docker/`** - Contains the source code for all custom nodes (routers, servers, Kali, etc.).
- **`docs/`** - Documentation source files, published at: [Full Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/).
- **`labs/`** - Topology design and configuration files for network device services.
- **`ml/`** - Full Machine Learning module: training data, pre-trained model, Jupyter notebook, and real-time detector.
- **`scripts/`** - Automation scripts for building images, managing labs, simulating attacks, and launching the ML detector.
- **`run.sh`** - Single entry point for all lab operations.
> **Git LFS:** The `.pkl` model files and `.json` dataset files in `ml/` are tracked with Git Large File Storage due to their size. Run `git lfs pull` after cloning.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

# Getting Started

## Prerequisites

| Requirement      | Minimum       | Notes                                                                                                |
|------------------|---------------|------------------------------------------------------------------------------------------------------|
| **OS**           | Ubuntu 22.04+ | Linux required                                                                                       |
| **RAM**          | 12 GB         | 20 GB for full ELK stack                                                                             |
| **CPU**          | 8 cores       | 12 cores recommended with monitoring                                                                 |
| **Docker**       | Latest        | Installed via Containerlab setup script                                                              |
| **Containerlab** | Latest        | [Installation guide](https://marc-chamorro.github.io/virtual-network-threat-detection/installation/) |
| **Python**       | 3.10+         | Required for ML module only                                                                          |
| **Git LFS**      | Latest        | Required to download model and dataset files                                                         |

> **Recommendation:** Use a dedicated VM to ensure no malicious traffic or content accidentally spreads to any sensitive device.

For detailed requirements, see: [Docs - Getting Started](https://marc-chamorro.github.io/virtual-network-threat-detection/getting-started/)

## Quick Installation

**1. Install Docker & Containerlab:**

```bash
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
```

Then add your user to the `clab_admins` group and re-login:

```bash
sudo usermod -aG clab_admins $USER
```

For detailed requirements, alternatives or any possible Docker installation issue, see [Docs - Installation](https://marc-chamorro.github.io/virtual-network-threat-detection/installation/).

**2. Clone the repository:**

```bash
git clone https://github.com/marc-chamorro/virtual-network-threat-detection.git
cd virtual-network-threat-detection
chmod +x run.sh
```

**3. Pull LFS files** (model and dataset files):

```bash
git lfs install
git lfs pull
```

## Execution

The project is managed via the `run.sh` interactive menu:

```bash
sudo ./run.sh
```

Use the interactive menu to first build images (*Image Control*) and then deploy the scenario (*Topology Control*).

> **Mandatory import:** External vendor images must be imported for the lab to work correctly. Follow the steps at: [Docs - External Images](https://marc-chamorro.github.io/virtual-network-threat-detection/docker/supported-images/?h=arista#arista-ceos)

## Typical Workflow

```
1. Build & Import Images -> 2. Deploy Topology -> 3. Analyse Traffic  4. Detect Anomalies (ML)
```

**1. Build & Import Images**  
Use the *Image Control* menu to build project images (`*_vntd`) and import mandatory vendor images like Arista cEOS.

**2. Deploy Topology**  
Select `topology.clab.yml` from the *Topology Control* menu to bring up the full enterprise network.

**3. Analyse Traffic**  
Once the network is up, traffic is automatically monitored by the IDS nodes. It may take a few minutes for the Elastic stack to fully boot. Logs are accessible via Kibana.

**4. Detect Anomalies (ML)**  
With the topology running, launch the real-time anomaly detector from the main menu:

```bash
sudo ./run.sh
# > Anomaly detection (ML) → Start real-time detection
```

The detector reads live Suricata logs from the `logwatch` container and scores each event against the pre-trained Isolation Forest model. See [Docs - ML](https://marc-chamorro.github.io/virtual-network-threat-detection/ml/) for full details.

For a full walkthrough of all script options, see the [Docs - Usage Guide](https://marc-chamorro.github.io/virtual-network-threat-detection/usage/).

## Available Architecture

All available topologies can be found in:

```
labs/
```

The primary scenario is an **Enterprise Network** segmented across multiple zones:

- **Internet Zone** - Simulates the Internet and publicly available services.
- **Attacker Network** - A hostile segment featuring Kali Linux for threat generation.
- **Benign Network** - A peaceful segment used to generate legitimate traffic.
- **Enterprise Infrastructure** - Segmented into functional VLANs:
  - **DMZ (VLAN 10):** Public-facing services (Web, Mail).
  - **Monitoring (VLAN 20):** Dedicated segment for IDS and log management.
  - **Administrators, Users & Internal:** Zones for administrative control, end-user devices, and internal services such as DHCP and FTP.

**Enterprise Main Lab:** `topology.clab.yml`; the core environment used for the TFG research.

![Example Topology](docs/assets/NET%20Design.svg)

Additional topologies can be added following the guidelines in: [Docs - Labs Overview](https://marc-chamorro.github.io/virtual-network-threat-detection/labs/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

# Monitoring

The infrastructure includes a dedicated **Logwatch node** that centralizes network logs for analysis. It makes use of the following tools:
 
| Tool              | Role          | Description                                                              |
|-------------------|---------------|--------------------------------------------------------------------------|
| **Suricata**      | Detection     | Network IDS that analyses traffic and generates structured JSON logs     |
| **Filebeat**      | Ingestion     | Log shipper that collects and forwards Suricata events to Elasticsearch  |
| **Elasticsearch** | Indexing      | Search and analytics engine that stores and indexes collected data       |
| **Kibana**        | Visualisation | Web interface to explore, analyse, and visualize data from Elasticsearch |
 
Data can be accessed directly from the host machine using the address provided by Containerlab. For more information, see [Docs - Monitoring - Kibana](https://marc-chamorro.github.io/virtual-network-threat-detection/monitoring/kibana/).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

# License

This project is developed as part of an academic Final Degree Project. See `LICENSE` for more information.

Distributed under the **GNU GPLv3 License**. This project is developed for academic and research purposes as part of a Final Degree Project. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

> **Author:** Marc Chamorro Mollon &nbsp;|&nbsp; **Tutor:** Pere Barberan Agut &nbsp;|&nbsp; **Year:** 2025–2026
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
    <li><a href="#project-structure">Project Structure</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#execution">Execution</a></li>
    <li><a href="#available-topologies">Available Topologies</a></li>
    <li><a href="#documentation">Additional Documentation</a></li>
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

# Project Structure

```
.
├─ docker/
│  ├─ README.md
│  └─ ...
├─ docs/
│  └─ ...
├─ labs/
│  ├─ README.md
│  └─ ...
├─ scripts/
│  ├─ README.md
│  └─ ...
├─ run.sh
└─ README.md
```

### Key Components

- `run.sh`: Main entry point for executing, building and deploying the lab.
- `docker/`: Contains the source code for the custom nodes (Routers, Kali, Servers, etc.).
- `docs/`: Documentation files, also available compiled at: [Documentation](https://marc-chamorro.github.io/virtual-network-threat-detection/)
- `labs/`: Contains the topology design and configuration files for individual network devices.
- `scripts/`: Internal logic used by the environment resource management.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Getting Started

## Prerequisites

The project is designed for Linux (Ubuntu 22.04+ recommended). Use a dedicated VM with at least 12GB of RAM if you plan to run the full environment.

For detailed requirements, see: [Prerequisites Documentation](./docs/getting-started.md) ([Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/))

### Installation

1. **Install Core Tools:** Follow the [Installation Guide](./docs/installation.md) ([Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/)) to set up Docker and Containerlab.

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

### Typical Workflow:

1. **Image Control:** Build your project images (*_vntd) and import external images.
2. **Topology Control:** Select a lab from the labs/ directory and deploy it.
3. **Analyze:** Once the network is up, traffic is automatically monitored by the IDS nodes.

For a full walkthrough of the script options, see the [Usage Guide](./docs/usage.md) ([Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/)).

## Available Topology

Allthe vaialable topologies provided can be found at:
```
labs/
```

The primary scenario provided is an **Enterprise Network** featuring a DMZ, Internal Workstations, and a Security Management zones.

**Enterprise Main Lab:** named `topology.clab.yml`, core environment used for the TFG research.

![Example Topology](images/NET%20Design.svg)

Additional topologies can be added by following the guidelines described in the topology documentation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Documentation

Detailed README documentation for each subsystem is provided in the corresponding directories:

- Topologies: [lab/README.md](/labs/README.md)
- Docker: [docker/README.md](/docker/README.md)
- Scripts: [scripts/README.md](/scripts/README.md)

Official documentation can be found at: [Docs](https://marc-chamorro.github.io/virtual-network-threat-detection/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# License

This project is developed as part of an academic Final Degree Project. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
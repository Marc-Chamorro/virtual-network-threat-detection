<a id="readme-top"></a>

<br />
<div align="center">

  <h3 align="center">Intelligent Threat Detection in Virtual Networks Using Containerlab and AI</h3>

  <p align="center">
    Final Degree Project (Treball de Fi de Grau)
    <br />
    Degree in Computer Engineering in Management and Information Systems
    <br />
    TecnoCampus, affiliated with Pompeu Fabra University
    <br />
    <br />
    <a href="#getting-started"><strong>Getting Started »</strong></a>
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

TO REWRITE THIS PART

This repository contains the implementation developed as part of a **Final Degree Project (TFG)**.  
The objective of the project is to **provide a working environment where others can simulate a simple enterprise environment to safely test a network and analyze generate malicious traffic and detect**.

The repository is organized to clearly separate:
- Core execution logic
- Configuration and topology definitions
- Supporting scripts and utilities
- Extended documentation per module

This `README.md` provides **general instructions** to set up and run the project.  
Each major directory contains its own `README.md` with **detailed technical explanations**.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Project Structure

```
.
├─ config/
│  └─ ...
├─ docker/
│  ├─ README.md
│  └─ ...
├─ images/
│  └─ ...
├─ labs/
│  └─ ...
├─ scripts/
│  └─ ...
├─ run.sh
└─ README.md
```
### Description
- `run.sh` Main entry point for executing the project.
REMOVE THIS, AS OF RIGHT NOW, INSIDE THE LABS FOLDER
- `config/` Configuration files used on the network devices. (MAYBE NOT NECESSARY / MOVE TO LABS)
- `images/` Figures used.
- `docker/` Image templates for customized containers.
- `labs/` Definitions of the provided network topologies.
- `scripts/` Additional scripts for environment and resource management.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Getting Started

This section describes how to set up the environment required to run the project locally.

## Prerequisites

The project assumes a **Linux-based environment**.

Required software:
- Bash? (which minimum version?)

## Installation

1. Containerlab installation
2. Ensure it works
3. Clone Git
4. chmod +x run.sh
5. Download the required images (hyperlink to the other readme maybe?)
6. Del projecte no copiar tot el vrnetlab, sino nomes le directori concret que necessitem per juniper
git submodule add https://github.com/vrnetlab/vrnetlab docker/vrnetlab
cd docker/vrnetlab
git sparse-checkout init --cone
git sparse-checkout set juniper/vjunosswitch common
git submodule update --remote
7. all teh scripts

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Execution

The project is executed through the run.sh script.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Available Topologies

Allthe vaialable topologies provided can be found at:
```
labs/
```
## Topology 1

The main provided topology...
![Example Topology](images/topology.png)

Additional topologies can be added by following the guidelines described in the topology documentation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# Documentation

Detailed documentation for each subsystem is provided in the corresponding directories:

- Topologies: [lab/README.md](/labs/README.md)
- Docker: [docker/README.md](/docker/README.md)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# License

This project is developed as part of an academic Final Degree Project. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
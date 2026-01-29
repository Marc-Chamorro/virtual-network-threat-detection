<a id="readme-top"></a>

# Automation & Control Scripts

This directory contains a set of scripts that manage the project's execution logic. These tools simplify the management of Docker images and Containerlab topologies, providing a unified and menu-driven interface for the user.

Even though these scripts can be run via the main control script `run.sh`, the logic is modularized into specialized subdirectories here.

## Table of Contents

- [Directory Structure](#directory-structure)
- [Usage](#usage)
- [Dependencies](#dependencies)
- [Additional Resources](#additional-resources)

## Directory Structure

```
scripts/
├── clab/               # Scripts for topology management
│   ├── deploy.sh       # Deploys a lab from labs/
│   ├── destroy.sh      # Destroys a running lab
│   ├── display.sh      # Lists available and running labs
│   └── menu.sh         # Interactive menu for Clab operations
├── images/             # Scripts for Docker image management
│   ├── create.sh       # Builds images from docker/build/
│   ├── delete.sh       # Removes *_vntd images
│   ├── display.sh      # Lists local project images
│   ├── import.sh       # Imports vendor images from docker/import/
│   └── menu.sh         # Interactive menu for Image operations
└── run.sh              # Main control script
```

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage

The recommended way to use these scripts is via the main script located at the root of the project:

```bash
./run.sh
```

However, advanced users can invoke individual scripts directly. Please refer to the [Scripts Overview](https://marc-chamorro.github.io/virtual-network-threat-detection/scripts/) in the documentation for argument requirements and detailed behavior.

<p align="right">(<a href="#top">back to top</a>)</p>

## Dependencies

These scripts rely on the following tools being installed and available in the system:
- **Docker:** For building and managing containers.
- **Containerlab (**`clab`**):** For deploying networking topologies.
- **Standard Utils:** `sh`, `basename`, `cut`, `tr`, `readlink`.

<p align="right">(<a href="#top">back to top</a>)</p>

## Additional Resources

Here are some additional resources that may help:

- Containerlab Commands: [Containerlab](https://containerlab.dev/cmd/deploy/)

- Docker Cheat Sheet: [Docker](https://docs.docker.com/get-started/docker_cheatsheet.pdf)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

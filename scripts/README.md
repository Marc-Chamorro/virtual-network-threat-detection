<a id="readme-top"></a>

# Topology Control Scripts

This directory contains a set of scripts designed to manage the containerized environment and its respective images. These scripts can be run via the main control script `run.sh` or individually from the command line.

## Table of Contents

- [Considerations](#considerations)
- [Directory Structure](#directory-structure)
- [Scripts Overview](#scripts-overview)
- [Additional Resources](#additional-resources)

## Considerations

The Included scripts provide a simple, menu-driven interface to handle environment operations. 

All operations are centralized through the main `run.sh` script, which acts as the control hub for:

- Docker image management
- Containerlab topology lifecycle management

This design allows users to interact with the environment without manually introducing commands.

The Containerlab deployment process depends on topology definition files (`*.clab.yml`) located in the `labs/` directory. Each topology defines nodes, links, images, and startup behavior.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Directory Structure
```
run.sh
scripts/
├─ clab/
│  └─ ... .sh
└─ images/
   └─ ... .sh
```
Each directory contains scripts related to a specific task:
- `clab/`: Containerlab topology management.
- `images/`: Docker image build and cleanup operations.

Additional directories used by the scripts:

- `labs/`: Contains Containerlab topology definition files (`*.clab.yml`). Each file represents a deployable network topology.
- `docker/build/`: Contains Docker image build directories. Each subdirectory represents one image:
   - One directory = one image.
   - The **directory name** becomes the image name, with `_vntd` appended to it (`<directory-name>_vntd`).
   - Each directory must contain a `Dockerfile`.

- `docker/import/`: Contains compressed image files (`.xz`) that can be imported directly into Docker using the provided import scripts.
  - The image name is the compressed file name trimmed by the character `-` with `_vntd` appended to it. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Scripts Overview

### run.sh

Serves as the main entry point for interacting with the project. It provides a simple, command-interactive user interface that guides the user through available operations.

- **Usage**: Central hub for launching all management scripts.
- **Arguments**: None required; it relies on the directory structure.
- **Functionality**: Prompts the user to choose between functionalities and delegates execution to the appropriate sub-script.

### clab/menu.sh

Provides an interactive menu for topology management operations.

- **Usage**: Executed after selecting topology control from `run.sh`.
- **Arguments**: Requires the project root directory.
```
./menu.sh /path/to/project/dir/virtual-network-threat-detection
```
- **Functionality**: Presents options to deploy, destroy, or display topologies and calls the corresponding script based on user input.

### clab/deploy.sh

Handles the deployment of containerlab network topologies.

- **Usage**:  Deploy a topology from the available `labs/` directory.
- **Arguments**: Requires the project labs directory.
```
./deploy.sh /path/to/project/dir/virtual-network-threat-detection/labs
```
- **Functionality**: Lists available topologies, checks for running instances, and deploys the selected topology.

### clab/destroy.sh

Destroys an active containerlab topology.

- **Usage**: Remove a running topology from the available `labs/` directory.
- **Arguments**: Requires the project labs directory.
```
./destroy.sh /path/to/project/dir/virtual-network-threat-detection/labs
```
- **Functionality**: Detects running topologies and allows the user to select one for destruction.

### clab/display.sh

Displays all project available topologies and running ones.

- **Usage**: View a list of available and running network topologies.
- **Arguments**: Requires the project labs directory.
```
./display.sh /path/to/project/dir/virtual-network-threat-detection/labs
```
- **Functionality**: Lists all available topologies and displays those currently deployed.

### images/menu.sh

Provides an interactive menu for managing Docker images related to the project.

- **Usage**: Executed after selecting image control from `run.sh`.
- **Arguments**: Requires the project root directory.
```
./menu.sh /path/to/project/dir/virtual-network-threat-detection
```
- **Functionality**: Offers options to create, delete, display, or import Docker images and delegates execution to the corresponding script.

### images/create.sh

Builds Docker images from the Dockerfiles provided.

- **Usage**: Build all project-specific images.
- **Arguments**: Requires the project root directory.
```
./create.sh /path/to/project/dir/virtual-network-threat-detection
```
- **Functionality**: Iterates the `docker/build/` directory and builds an image for each available directory present. For each image built, `_vntd` is appended to identify the project images.

### images/delete.sh

Deletes Docker images related to the project.

- **Usage**: Remove all project-specific Docker images.
- **Arguments**: None.
```
./delete.sh
```
- **Functionality**: Forcefully removes all Docker images matching the `*_vntd` tag.

### images/display.sh

Displays all Docker images built related to the project.

- **Usage**: List available project images. 
- **Arguments**: None.
```
./display.sh
```
- **Functionality**: Displays all Docker images tagged with `_vntd`.

### images/import.sh

Imports compressed network images.

- **Usage**: Import `.xz` images into Docker.
- **Arguments**: Requires the project root directory.
```
./import.sh /path/to/project/dir/virtual-network-threat-detection
```
- **Functionality**: Iterates through `.xz` files in the import directory, extracts them, and imports each image into Docker with the `_vntd` tag.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Additional Resources

Here are some additional resources that may help:

- Containerlab Commands: [Containerlab](https://containerlab.dev/cmd/deploy/)

- Docker Cheat Sheet: [Docker](https://docs.docker.com/get-started/docker_cheatsheet.pdf)

<p align="right">(<a href="#readme-top">back to top</a>)</p>
# Installation Guide

This guide details the step-by-step process to set up the **Laboratory** environment. These instructions assume you are running a fresh installation of **Ubuntu 25.10** (or similar Debian-based OS) within a controlled environment.

The official Containerlab installation process can be found at: [Containerlab Install](https://containerlab.dev/install/)

## 1. Prepare the System

Before installing the core tools, ensure your system is up to date and essential utilities are installed.

### Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### Install Essential Utilities

Install curl for downloading scripts and ssh for managing connectivity to the virtual nodes.

```bash
sudo apt install -y curl git
sudo apt install -y ssh
```

!!! note
    Installing SSH independently is recommended as it is later utilized by Containerlab to manage virtual devices.

## 2. Install Containerlab & Docker

Docker is the engine that manages the virtual nodes, and Containerlab is the tool that allows the deployment and connection of containers. While these can be installed separately, the official Containerlab page provides a script to automatically install the latest versions of both services.

### Installation

```bash
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
```
To be more specific, this command:
- Installs the `git` and `make` packages
- Installs Docker
- Installs Containerlab
- Configures permissions and SSH access

!!! note
    Docker may not install properly (a common issue). Alternative commands to install Docker are:
    ``` bash
        curl -sL https://containerlab.dev/setup | sudo -E bash -s "install-docker" 
    ```
    ``` bash
        curl -sSL https://get.docker.com/ | sudo sh
    ```

### Configure Permissions

By default, Docker requires root privileges. To run Docker commands as a standard user, you must add your user to the docker group.

```bash
sudo usermod -aG clab_admins $USER
```

!!! important 
    "Apply Changes" You must log out and log back in (or restart the VM) for the group membership to take effect.

## 3. Install Containerlab

Containerlab orchestrates the Docker containers to form the network topology. The installation is handled by an automated script provided by the Containerlab developers.

```bash
# Download and install Containerlab
bash -c "$(curl -sL [https://containerlab.dev/setup](https://containerlab.dev/setup))"
```

### Containerlab Permissions

To allow Containerlab to manage network interfaces without constant sudo prompts, add your user to the clab_admins group (created during installation).

```bash
sudo usermod -aG clab_admins "$USER"
```

## 4. Verify Installation

Once all components are installed and you have re-logged into your session, verify that the environment is operational.

### Verify Docker

Run the "hello-world" container to ensure the Docker daemon is active and accessible.

```bash
docker run hello-world
```

### Verify Containerlab

Check the installed version to ensure the binary is in your PATH.

```bash
clab version
```

## 5. Clone the Repository

Finally, clone the project repository to your local machine to access the topology definitions, scripts, and Dockerfiles.

```bash
git clone https://github.com/Marc-Chamorro/virtual-network-threat-detection
cd virtual-network-threat-detection/
```

You are now ready to build the images and deploy the labs.

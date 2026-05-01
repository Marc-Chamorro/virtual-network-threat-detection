---
title: Installation
icon: material/download-outline
---

# Installation Guide

This guide details the **step-by-step process** to set up the **Laboratory** environment. 

These instructions assume you are running a fresh installation of **Ubuntu 25.10** (or similar Debian-based OS) within a controlled environment.

The official Containerlab installation process can be found at: [Containerlab Install](https://containerlab.dev/install/)

---

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

!!! note "SSH Installation"
    Installing SSH independently is recommended as it is later utilized by Containerlab to manage virtual devices.

---

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

!!! note "Alternative Docker Installation"
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

!!! warning "Apply Changes" 
    You must log out and log back in (or restart the VM) for the group membership to take effect.

---

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

---

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

---

## 5. Clone the Repository

Finally, clone the project repository to your local machine to access the topology definitions, scripts, and Dockerfiles.

```bash
git clone https://github.com/Marc-Chamorro/virtual-network-threat-detection
cd virtual-network-threat-detection/
```

!!! important "Git LFS"
    This project uses **Git Large File Storage (LFS)** to manage large binary files (model files and training datasets). After cloning, ensure LFS objects are downloaded:

    - If you already have Git LFS installed before cloning, the large files are downloaded automatically.
    - If not, follow the steps below.

    **Install Git LFS (Ubuntu/Debian):**
    ```bash
    sudo apt install git-lfs
    ```

    **Initialize Git LFS (one-time setup):**
    ```bash
    git lfs install
    ```

    **If you cloned the repository before installing Git LFS, run:**
    ```bash
    git lfs pull
    ```

You are now ready to [build the images and deploy the labs](./usage.md).

---

## 6. ML Environment {#ml-environment}

The ML module requires an additional Python environment on the **host machine**. This is only needed if you intend to use the real-time anomaly detector or retrain the model.

!!! note "Scope"
    This section is independent from the Docker/Containerlab setup. The main lab (Docker containers) does not need Python on the host.

### Install Python

```bash
sudo apt install -y python3 python3-pip python3-venv
```

Verify:

```bash
python3 --version
```

### Create the Virtual Environment

A virtual environment isolates the ML dependencies from the system Python installation. Create it at the project root:

```bash
python3 -m venv venv
```

Activate it:

```bash
source venv/bin/activate
```

The terminal prompt will show `(venv)` when the environment is active.

### Install Dependencies

```bash
pip install -r ml/requirements.txt
```

This installs the packages required for both the Jupyter notebook and the real-time detector:

| Package        | Purpose                                         |
|----------------|-------------------------------------------------|
| `scikit-learn` | Isolation Forest model, StandardScaler, metrics |
| `pandas`       | DataFrame loading and manipulation              |
| `numpy`        | Numeric operations                              |
| `joblib`       | Saving and loading trained model objects        |

### Launch Jupyter (Training / Retraining)

To open the notebook and retrain the model:

```bash
source venv/bin/activate
jupyter notebook ml/notebooks/VNTD_ML.ipynb
```

The browser will open at `http://localhost:8888`. If running on a headless VM, see [ML Environment Setup - Remote Jupyter](./ml/setup.md#accessing-jupyter-from-another-machine).

### Real-Time Detection

To launch the anomaly detector without opening Jupyter, use the main menu:

```bash
sudo ./run.sh
```

The `ml_detect.sh` script handles virtual environment creation and dependency installation automatically.

!!! info "Full ML documentation"
    For a complete guide to the ML module, see:
 
    - [ML Overview](./ml/index.md)
    - [ML Environment Setup](./ml/setup.md)
    - [ML Scripts](./scripts/ml.md)
 

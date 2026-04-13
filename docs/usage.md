---
title: Usage
icon: material/hammer-wrench
---

# Usage Guide

The project is controlled primarily through a **centralized automation script**: `run.sh`. This script manages both Docker and Containerlab, ensuring project naming conventions (`_vntd` suffix) are maintained.

---

## Core Logic: `run.sh`

To start the control menu, navigate to the project root and execute:

```bash
sudo ./run.sh
```

!!! note "Execution"
    Change the scripts permissions with: `chmod +x run.sh`.

!!! tip "Automation first"
    Always prefer using the `run.sh` commands over manual Docker or Containerlab commands to ensure the environment remains consistent with the documentation and security policies.

---

## Recommended Workflow

For standard usage of the environment, follow these steps:

1. **Preparation:** Ensure your vendor images (like cEOS) are in docker/import/ and run `Image Control` -> `Create` and `Import` to build/import required images.

2. **Deployment:** Go to `Topology Control` -> `Deploy` and select your desired scenario (default scenario: `topology.clab.yml`).

3. **Verification:** Once the deployment finishes, use status of the environment will appear on the screen along the state of all nodes.

4. **Experimentation:** Access the nodes via SSH or `docker exec` to perform traffic generation or security analysis.

5. **Cleanup:** Always run `Topology Control` -> `Destroy` before finishing your session to ensure system resources are released.

---

## Management Modules

=== "Image Management"

    Access this menu to handle the lifecycle of the Docker containers. All images managed through this menu are automatically appended with the `_vntd` suffix to distinguish them from other images on your system.

    - **Create Images:** Scans the `docker/build/` directory and builds every valid image found. It automates the tagging process so the images are ready for deployment.

    - **Import Images (.tar.xz):** Scans the `docker/import/` directory for vendor-provided images (e.g., Arista cEOS). It automatically imports and tags them with the previous format.

    - **Delete Images:** A cleanup utility that removes all local images containing the `_vntd` tag. This is useful for clearing disk space or forcing a fresh rebuild.

    - **Display Images:** Lists all currently available images in your local Docker registry that belong to this project.

    !!! info "Pro-Tip: Ignore Images"
        Directories in `docker/build/` starting with an underscore (e.g., `_mls`) are **ignored** by the automatic build process.

=== "Topology Management"

    Orchestrate the network simulation using Containerlab.

    - **Deploy Topology:** Displays available topologies within the `labs/` directory and allows you to select one to launch. This command handles the creation of the virtual environment.

    - **Destroy Topology:** Stops all running containers from a specific lab and removes the network interfaces and bridges created by Containerlab. This should always be done before closing the machine to avoid future networking issues.

    - **Display Available Topologies:** Lists the lab scenarios currently defined in the `labs/` folder and indicates on screen the active/running ones.

    !!! warning "Cleanup"
        Always destroy active topologies before shutting down the system to avoid networking or performance issues.

---

## Connectivity

Connectivity to a node can be achieved by executing:

```bash
docker exec -it <container_name> bash
```

The `bash` element opens an interactive shell inside the container; it can be replaced with any other CLI command.

---

## Extending the Lab

New topologies can be added into the project and may reuse components, coexist with other scenarios while keeping changes at the core of the architecture minimal.

!!! info "More topologies"
    Additional topologies can be added to the `labs/` directory. Configuration elements and machines can be reused across multiple nodes.

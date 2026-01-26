# Usage Guide

This section provides a detailed explanation of the workflow required to operate the virtual laboratory.

## Core Logic: The `run.sh` Script

To simplify the complexity of managing multiple Docker builds, image imports, and network orchestrations, this project utilizes a centralized automation script: `run.sh`.

!!! note
    Change the scripts permissions with: `chmod +x run.sh`

This script acts as a manager for both **Docker** and **Containerlab**, ensuring that all operations follow the project's naming conventions (like the `_vntd` suffix) and directory structures.

To start the control menu, navigate to the project root and execute:

```bash
./run.sh
```

The script organizes into diverse following main categories.

---

## Recommended Workflow

!!! tip "Automation first"
    Always prefer using the `run.sh` commands over manual Docker or Containerlab commands to ensure the environment remains consistent with the documentation and security policies.

For standard usage of the environment, follow these steps:

1. **Preparation:** Ensure your vendor images (like cEOS) are in docker/import/ and run Image Control -> Create and Import.

2. **Deployment:** Go to Topology Control -> Deploy and select your desired scenario (default scenario: `topology.clab.yml`).

3. **Verification:** Once the deployment finishes, use status of the environment will appear on the screen along the state of all nodes.

4. **Experimentation:** Access the nodes via SSH or docker exec to perform traffic generation or security analysis.

5. **Cleanup:** Always run Topology Control -> Destroy before finishing your session to ensure system resources are released.

---

## Image Management

Access this menu to handle the lifecycle of the Docker containers that act as network nodes. All images managed through this menu are automatically appended with the `_vntd` suffix to distinguish them from other images on your system.

!!! info "Pro-Tip: Ignore Images"
    If you are modifying a Dockerfile and want to test it without affecting the main deployment, remember that directories in docker/build/ starting with an underscore (_) are ignored by the automatic "Create images" process.

### Actions:

- **Create Images:** Scans the docker/build/ directory and builds every valid image found. It automates the tagging process so the images are ready for deployment.

- **Import Images (.tar.xz):** Scans the docker/import/ directory for vendor-provided images (e.g., Arista cEOS). It automatically imports and tags them with the previous format.

- **Delete Images:** A cleanup utility that removes all local images containing the _vntd tag. This is useful for clearing disk space or forcing a fresh rebuild.

- **Display Images:** Lists all currently available images in your local Docker registry that belong to this project.

---

## Topology Management

Once your images are ready, use the Topology Control menu to orchestrate the network simulation using Containerlab.

!!! info "More topologies"
        Additional topologies can be added to the `labs` directory. Configuration elements and machines can be reused across multiple nodes.

### Actions:

- **Deploy Topology:** Displays available topologies within the labs/ directory and allows you to select one to launch. This command handles the creation of the virtual environment.

- **Destroy Topology:** Stops all running containers from a specific lab and removes the network interfaces and bridges created by Containerlab. This should always be done before closing the machine to avoid future networking issues.

- **Display Available Topologies:** Lists the lab scenarios currently defined in the labs/ folder and indicates on screen the active/running ones.

---

## Connectivity

Connectivity to a node can be achieved by executing:

```bash
docker exec -it <container_name> bash
```

The `bash` element opens an interactive shell inside the container; it can be replaced with any other CLI command.

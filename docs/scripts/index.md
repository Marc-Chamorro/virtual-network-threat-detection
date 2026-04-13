---
title: Scripts & Automation Overview
icon: material/file-code-outline
---

# Scripts & Automation Overview

To minimize human errors and automate the workflow, the project includes a comprehensive set of automation scripts. These tools manage the entire lifecycle of the laboratory, from building custom Docker images to orchestrating complex network topologies with Containerlab

---

## Core Philosophy

The automation framework is built upon three fundamental principles:

<div class="grid cards" markdown>

-   :material-hub:{ .lg .middle } **Centralized Control**

    ---

    A single entry point (`run.sh`) provides access to every management function, eliminating the need to memorize complex CLI flags.

-   :material-tag-outline:{ .lg .middle } **Naming Conventions**

    ---

    The system automatically enforces project-specific tags (using the `_vntd` suffix) to prevent conflicts with other local Docker resources.

-   :material-monitor-dashboard:{ .lg .middle } **Interactive Guidance**

    ---
    
    User-friendly interfaces that guide the operator through operations by removing the needing of memorize complex flags or instructions.

</div>

---

## Main Entry Point: `run.sh`

The `run.sh` script, located at the project root, serves as the main entry point for interacting with the environment. It acts as a wrapper that delegates tasks to specialized scripts in the `scripts/` directory.

### Execution

To launch the project management menu, execute:

```bash
sudo ./run.sh
```

!!! note "Permissions"
    Ensure the script is executable before the first run: `chmod +x run.sh`

---

## Navigation

The automation logic is divided into two modules:

- [**Lab Management**](./lab-management.md): Orchestrates Containerlab deployments and monitors active topologies.
- [**Image Management**](./images-management.md): Automates Docker build, import, and cleanup operations.
- [**Attack Simulations**](attacks/index.md): Execute controlled attacks against the simulated network.

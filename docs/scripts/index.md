# Scripts & Automation Overview

To minimize human errors and automate the workflow, the project includes a set of automation scripts. These scripts handle the repetitive tasks of building Docker images, managing lifecycle states, and interacting with the Containerlab orchestrator.

## Core Philosophy

The automation is built around three principles:

1.  **Centralized Control:** A single entry point (`run.sh`) manages the entire environment.
2.  **Naming Convention:** Automatically appends `_vntd` to all images to prevent conflicts with other local projects.
3.  **Interactive Menus:** User-friendly interfaces that guide you through operations without needing to memorize complex flags or instructions.

## Run script (`run.sh`)

Serves as the main entry point for interacting with the project. It provides a simple, command-interactive user interface that guides the user through available operations.

**Role:** Central hub for launching all management scripts.
**Input:** None required; it relies on the directory structure.
**Behavior:** Prompts the user to choose between functionalities and delegates execution to the appropriate sub-script.
**Command:**
```bash
./run.sh
```

## Navigation

- [**Lab Management**](./lab-management.md): Detailed documentation on the scripts that deploy, destroy, and inspect network topologies.
- [**Image Management**](./images-management.md): Explanations of how the build system constructs, imports and manages Docker images.

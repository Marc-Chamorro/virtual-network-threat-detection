---
title: Lab Management Scripts
icon: material/lan-connect
---

# Lab Management Scripts

Located in `scripts/clab/`, these **Containerlab** scripts provide a text-based interface to ensure safer and more convenient user experience. They handle automatic topology discovery and status checking.

---

## Interactive Controller: `menu.sh`

- **Role:** The controller for all topology operations.
- **Input:** Project root directory.
- **Behavior:** Presents options to deploy, destroy, or display topologies and calls the corresponding script based on user input.
- **Command:**
    ```bash
    ./menu.sh /path/to/project/dir/virtual-network-threat-detection
    ```

---

## Core Operations

### Topology Deployment (`deploy.sh`)

- **Role:** Deploys a network topology.
- **Input:** Project `lab/` directory.
- **Workflow:**
    1. **Scanning:** Looks for `*.clab.yml` files in the `labs/` directory.
    2. **Status Check:** Warns if other topologies are currently running to prevent excessive resource consumption.
    3. **Selection:** Prompts the user to select a lab from a numbered list.
    4. **Execution:** Invokes `clab deploy --topo <selected_file>`.
    5. **Isolation:** Applies network isolation rules using `iptables`.
- **Isolation Details:**
    - Internal lab traffic (bridge-to-bridge) is allowed.
    - Traffic leaving the lab is blocked by default.
    - A specific device (`logwatch`) is allowed external access (requires internet access for setting up the environment).

    The script dynamically searchs the expected container name:
    >clab-<lab-name>-logwatch

    - If the device is found:
        - Its IP is retrieved.
        - Outbound traffic and return traffic are allowed.
        - NAT (MASQUERADE) is applied so it can reach external networks.

    - If the device is not found:
        - The script continues normally.
        - Only general isolation rules are applied.

    This ensures compatibility with topologies that do not include a logwatch node.

**Command:**
```bash
./deploy.sh /path/to/project/dir/virtual-network-threat-detection/labs
```

!!! warning "Dependencies"
    These scripts rely on `iptables` to enforce network isolation. Ensure it is installed and available on the host device.

!!! important "Sudo"
    Due to the use of `iptables`, root privileges are required. Run the scripts with `sudo` or ensure the user has the necessary permissions.

### Environment Destruction (`destroy.sh`)

- **Role:** Destroys a running topology.
- **Input:** Project `lab/` directory.
- **Workflow:**
    1. **Isolation Cleanup:** Removes previously applied network isolation rules.
    2. **Status Check:** Uses `clab inspect` to verify if any labs are active and, if not, stops the process.
    3. **Scanning:** Looks for `*.clab.yml` files in the `labs/` directory.
    4. **Selection:**  Prompts the user to select a lab from a numbered list.
    5. **Execution:** Invokes `clab destroy -t <selected_file>`. This stops containers and removes virtual bridges.
- **Isolation Cleanup Details:**
    - The script attempts to locate the logwatch container using the same naming format.
    - If found:
        - Removes forwarding exceptions and NAT rules associated with it.
    - If not found:
        - Skips logwatch-specific cleanup.
    - General isolation rules are always removed.

    This guarantees cleanup works even if the container is no longer running or was never deployed.

**Command:**
```bash
./destroy.sh /path/to/project/dir/virtual-network-threat-detection/labs
```

### Visibility and Inspection (`display.sh`)

- **Role:** Provides environment state visibility.
- **Input:** Project `lab/` directory.
- **Behavior:** Lists all `*.clab.yml` files found in the `labs/` folder and displays all active topologies with their respective nodes.
- **Command:**
    ```bash
    ./display.sh /path/to/project/dir/virtual-network-threat-detection/labs
    ```

!!! danger "Persistence Practise"
    Avoid storing permanent configuration files inside the `clab-<name>` directories generated during deployment. Use the project's `config/` directory and binds instead.

---

## Technical Summary

| Function    | Command Path              | Target Directory |
|:------------|:--------------------------|:-----------------|
| **Deploy**  | `scripts/clab/deploy.sh`  | `lab/`           |
| **Destroy** | `scripts/clab/destroy.sh` | `lab/`           |
| **Display** | `scripts/clab/display.sh` | `lab/`           |

!!! tip "Free Resources"
    After using the environment, stop it to ensure no unnecessary resources are consumed.

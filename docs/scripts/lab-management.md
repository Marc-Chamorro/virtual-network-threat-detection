# Lab Management Scripts

Located in `scripts/clab/`, these **Containerlab** scripts provide a text-based interface to ensure safer and more convenient user experience. They handle automatic topology discovery and status checking.

## Interactive Menu (`clab/menu.sh`)

**Role:** The controller for all topology operations.
**Input:** Project root directory.
**Behavior:** Presents options to deploy, destroy, or display topologies and calls the corresponding script based on user input.
**Command:**
```bash
./menu.sh /path/to/project/dir/virtual-network-threat-detection
```

## Deploy Script (`clab/deploy.sh`)

**Role:** Deploys a network topology.
**Input:** Project `lab/` directory.
**Workflow:**
1.  **Scanning:** Looks for `*.clab.yml` files in the `labs/` directory.
2.  **Status Check:** Warns if other topologies are currently running to prevent excessive resource consumption.
3.  **Selection:** Prompts the user to select a lab from a numbered list.
4.  **Execution:** Invokes `clab deploy --topo <selected_file>`.
**Command:**
```bash
./deploy.sh /path/to/project/dir/virtual-network-threat-detection/labs
```

## Destroy Script (`clab/destroy.sh`)

**Role:** Destroys a running topology.
**Input:** Project `lab/` directory.
**Workflow:**
1. **Status Check:** Uses `clab inspect` to verify if any labs are active and, if not, stops the process.
2. **Scanning:** Looks for `*.clab.yml` files in the `labs/` directory.
3. **Selection:**  Prompts the user to select a lab from a numbered list.
3. **Execution:** Invokes `clab destroy -t <selected_file>`. This stops containers and removes virtual bridges.
**Command:**
```bash
./destroy.sh /path/to/project/dir/virtual-network-threat-detection/labs
```

## Display Script (`clab/display.sh`)

**Role:** Provides environment state visibility.
**Input:** Project `lab/` directory.
**Behavior:** Lists all `*.clab.yml` files found in the `labs/` folder and displays all active topologies with their respective nodes.
**Command:**
```bash
./display.sh /path/to/project/dir/virtual-network-threat-detection/labs
```
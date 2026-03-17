---
title: Attack Simulations
icon: material/sword
---

# Attack Simulations

The laboratory is designed not only to simulate enterprise infrastructure but also to **observe and analyze malicious activity** in a controlled environment.

This section documents the different provided **attack simulations** that can be performed against the network.

---

## Objectives

Attack scenarios serve several purposes:

- Understanding common network attack techniques.
- Observing attacker behavior in realistic environments.
- Learning how monitoring systems detect malicious activity.
- Practicing threat analysis using logging platforms.

Because the laboratory environment integrates **Suricata**, **Filebeat**, **Elasticsearch**, and **Kibana**, every attack produces registers that can be analyzed.

---

## Attack Environment

All attacks must be executed inside the simulated network environment.

!!! important "Controlled Environment"
    Attack simulations must always remain inside the laboratory environment.
    These exercises and templates are intended only for educational and testing purposes.

---

## Adding New Attack Scenarios

Attack simulations are implemented as **scripts** executed from the project entrypoint.

All attack scripts must be placed inside the directory:

> scripts/attacks/

This directory acts as a storage for the **available attack simulations**. Each script added to this folder automatically becomes available through the main project execution entrypoint. This modular design allows new attacks to be added easily without modifying the automation framework.

---

### Script Requirements

Every attack script must follow a minimal structure so it can be properly integrated into the system.

<div class="grid cards" markdown>

-   :material-script-text:{ .lg .middle } **Fail Fast**

    ---

    Scripts must include `set -e` to immediately stop execution if an error occurs.

    Although the comments are not strictly necessary, it is highly recommended. It helps users understand how to manually execute the script from the terminal and how the script is intended to be used.

    ```sh
    #!/bin/sh
    set -e

    # Example execution:
    # ./port_scanning.sh clab-virtual-env-attacker
    # ./port_scanning.sh clab-virtual-env-attacker enterprise.com
    # ./port_scanning.sh clab-virtual-env-attacker 172.16.30.2
    ```

-   :material-menu:{ .lg .middle } **Menu Name Support**

    ---

    Scripts must support the `-n` flag to return the name shown in the automation menu.

    ```sh
    if [ "$1" = "-n" ]; then
        echo "Port scanning | nmap"
        exit 0
    fi
    ```

-   :material-docker:{ .lg .middle } **Container Execution**

    ---

    If attacks are to be executed using the `docker exec` tool, the script should make sure the container name is available.

    ```sh
    if [ -z "$1" ]; then
        echo "Usage: $0 <attacker-container>"
        exit 1
    fi
    ```

-   :material-file-code:{ .lg .middle } **Self**

    ---

    Each script should implement a single attack scenario and remain independent from others.

    ```sh
    docker exec "$ATTACKER_CONTAINER" <instruction>
    ```

</div>

---

## Security Disclaimer

The attack techniques described in this section are intended strictly for educational use inside the VNTD laboratory.

!!! warning "Responsible Use"
    These techniques ***must never be used against real systems*** without explicit authorization.

---

## Attack Scenarios

Currently available attacks:

- [Port Scanning](port_scanning.md): Scan all available ports and services from a node.
- [TCP SYN Flood (DoS)](dos_syn_flood_hping3.md): Send a high volume of SYN packages to a target to disrupt connections and exhaust resources.

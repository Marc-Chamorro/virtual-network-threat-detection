---
title: Attack Simulations
icon: material/sword
---

# Attack Simulations

The laboratory is designed not only to simulate enterprise infrastructure but also to **observe and analyze malicious activity** in a controlled environment.

This section documents the **attack simulations** that can be performed against the network.

---

## Objectives

Attack scenarios serve several purposes:

- Understanding common network attack techniques
- Observing attacker behaviour in realistic environments
- Learning how monitoring systems detect malicious activity
- Practising threat analysis using logging and visualization platforms

Because the laboratory integrates **Suricata**, **Filebeat**, **Elasticsearch**, and **Kibana**, every attack produces logs and alerts that can be analyzed after the fact.

---

## Attack Environment

All attacks must be executed inside the simulated network environment.

!!! important "Controlled Environment"
    Attack simulations must always remain inside the laboratory environment.
    These scripts are intended strictly for educational and research purposes.

---

## Adding New Attack Scenarios

All attack scripts must be placed inside:

> `scripts/attacks/`

Every file added to this directory is automatically discovered by the main execution menu. Each script must implement the `-n` flag to return a short display name and accept the attacker container name as its first argument. See the [Script Requirements](#script-requirements) section below.

---

### Script Requirements

Every attack script must follow a minimal structure to integrate cleanly with the automation framework.

<div class="grid cards" markdown>

-   :material-script-text:{ .lg .middle } **Fail Fast**

    ---

    Include `set -e` at the top so the script exits immediately on any unexpected error.

```sh
    #!/bin/sh
    set -e

    # Example execution:
    # ./port_scanning.sh clab-virtual-env-attacker
    # ./port_scanning.sh clab-virtual-env-attacker 172.16.30.2
```

-   :material-menu:{ .lg .middle } **Menu Name**

    ---

    Support the `-n` flag to return the label shown in the interactive menu.

```sh
    if [ "$1" = "-n" ]; then
        echo "Port Scanning | nmap"
        exit 0
    fi
```

-   :material-docker:{ .lg .middle } **Container Argument**

    ---

    Accept the attacker container name as `$1` and validate it is provided.

```sh
    if [ -z "$1" ]; then
        echo "Usage: $0 <attacker-container> [target]"
        exit 0
    fi

    ATTACKER_CONTAINER="$1"
```

-   :material-file-code:{ .lg .middle } **Single Responsibility**

    ---

    Each script implements one attack scenario and remains independent.

```sh
    docker exec "$ATTACKER_CONTAINER" <command>
```

</div>

---

## Security Disclaimer

The attack techniques described here are intended strictly for educational use inside the VNTD laboratory.

!!! warning "Responsible Use"
    These techniques **must never be used against real systems** without explicit written authorisation.

---

## Available Attack Scenarios

| Attack                                          | Tool                 | Purpose                                                                        |
|-------------------------------------------------|----------------------|--------------------------------------------------------------------------------|
| [Port Scanning](port_scanning.md)               | nmap                 | Enumerate open ports, services and OS on a target                              |
| [TCP SYN Flood](dos_syn_flood_hping3.md)        | hping3               | Exhaust the server connection table with half-open TCP sessions                |
| [Slow HTTP DoS](dos_slow_http_slowloris.md)     | Slowloris            | Exhaust web server threads with partial long-lived HTTP connections            |
| [SSH Brute Force](ssh_bruteforce_hydra.md)      | hydra                | Discover valid SSH credentials through automated password guessing             |
| [OSPF Route Hijack](ospf_route_hijack.md)       | FRR vtysh + nginx    | Redirect traffic by injecting a more-specific route into the OSPF domain       |
| [SMTP Recon + Relay Abuse](smtp_recon_abuse.md) | nmap + swaks + hydra | Enumerate mail users, test open relay, send spoofed mail, and brute-force IMAP |
| [Dataset Generation](generate_traffic.md)       | multiple             | Generate a full labeled benign + attack register for ML training               |

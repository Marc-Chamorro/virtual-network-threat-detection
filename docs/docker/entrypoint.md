---
title: Entrypoints & Runtime Behavior
icon: material/script-text
---

# Entrypoints & Runtime Behavior

The `entrypoint.sh` script defines the **logic** to be executed at startup time. Unlike the `Dockerfile` (which defines the static content), the entrypoint defines the **runtime configuration** once the container initializes.

---

## The Role of Entrypoints

In this virtual lab environment, entrypoints serve three critical functions:

1.  **Network Initialization:** Enabling IP forwarding or bridging, allowing containers to function as routers.
2.  **Sanitization:** Clearing pre-existing firewall rules to ensure no leftover configurations interfere with the lab topology.
3.  **Service Orchestration:** Starting background daemons based on variables before holding the container open.

---

## Common Routines

### Enabling IP Forwarding

For a Linux container to act as a router (passing packets between interfaces), IP forwarding must be enabled in the kernel. This is typically done in the entrypoint:

```bash
sysctl -w net.ipv4.ip_forward=1
```

### Firewall Sanitization

Images like `firewall_vntd` and `router_vntd` often include commands to flush iptables rules. This ensures that the device starts with a known state, rather than inheriting random rules or Docker's default NAT rules that might interfere with the lab topology.

```Bash
# Example from firewall entrypoint
iptables -F         # Flush filter table
iptables -t nat -F  # Flush NAT table
iptables -X         # Delete user-defined chains
```

### The "Keep-Alive" Loop

Because containers are *ephemeral* (lasting for a short time), the script must not end. If the script finishes, the container dies. The standard way to keep the node active in Containerlab is:

```Bash
sleep infinity
```

---

## Special Cases

The server entrypoint utilizes environment variables passed by Containerlab to decide which services to launch at boot.

!!! note "Dynamic Entrypoint"
    This feature is not limited to the `server_vntd` image, other images also offer this feature. Although not as many services are provided.

**Logic Flow Example:**

```mermaid
graph TD
    Start[Container Start] --> CheckSSH{SSH_SERVER=1?}
    CheckSSH -- Yes --> StartSSH[Create user vntd & Start SSHD]
    CheckSSH -- No --> CheckWeb{WEB_SERVER=1?}
    CheckWeb -- Yes --> StartWeb[Generate HTML & Start Nginx]
    CheckWeb -- No --> Persistence[Execute sleep infinity]
    StartSSH --> CheckWeb
    StartWeb --> Persistence
---

!!! example

    1. Check if `SSH_SERVER=1` $\rightarrow$ Configure keys, create user, start sshd.
    2. Check if `WEB_SERVER=1` $\rightarrow$ Generate index.html, start nginx.
    3. Execute `sleep infinity`.

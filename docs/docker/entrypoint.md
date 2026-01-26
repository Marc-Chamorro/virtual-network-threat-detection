# Entrypoints & Runtime Behavior

The `entrypoint.sh` script is the logic to be executed at startup time. Unlike the `Dockerfile` (which defines the static content), the entrypoint defines the **runtime configuration** once the container initializes.

## The Role of Entrypoints

In this virtual lab environment, entrypoints serve three critical functions:

1.  **Network Initialization:** Enabling IP forwarding or bridging.
2.  **Sanitization:** Clearing pre-existing firewall rules to ensure a clean slate.
3.  **Service Orchestration:** Starting background daemons (SSH, Nginx) before holding the container open.

---

## Common Routines

### Enabling IP Forwarding

For a Linux container to act as a router (passing packets between interfaces), IP forwarding must be enabled in the kernel. This is typically done in the entrypoint:

```bash
sysctl -w net.ipv4.ip_forward=1
```

### Firewall Sanitization

Images like firewall_vntd and router_vntd often include commands to flush iptables rules. This ensures that the device starts with a known state, rather than inheriting random rules or Docker's default NAT rules that might interfere with the lab topology.

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

The server image demonstrates a dynamic entrypoint. It checks environment variables passed from the clab file to decide which services to start.

**Logic Flow:**

1. Check if `SSH_SERVER=1` $\rightarrow$ Configure keys, create user, start sshd.
2. Check if `WEB_SERVER=1` $\rightarrow$ Generate index.html, start nginx.
3. Execute `sleep infinity`.

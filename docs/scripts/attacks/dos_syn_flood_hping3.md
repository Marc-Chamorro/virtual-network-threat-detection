---
title: TCP SYN Flood (DoS)
icon: material/alert-octagon
---

# TCP SYN Flood (DoS)

This scenario performs a **Denial-of-Service (DoS) attack** using a TCP SYN flood generated with `hping3` from an attacker container.

The script sends a high volume of SYN packets to a target host in order to exhaust server resources and disrupt normal connections.

---

## Attack Script

Location:
> `scripts/attacks/dos_syn_flood_hping3.sh`

Example usage:

```bash
./scripts/attacks/dos_syn_flood_hping3.sh clab-virtual-env-attacker
```

Specify target, port, and duration manually:

```bash
./scripts/attacks/dos_syn_flood_hping3.sh clab-virtual-env-attacker 172.16.30.2 80 120
```

| Parameter          | Description                                  |
|--------------------|----------------------------------------------|
| attacker-container | Container executing the attack               |
| target             | Target host (optional)                       |
| port               | Target port (optional)                       |
| timeout            | Duration of the attack in seconds (optional) |

If no target is specified, the script attacks: `enterprise.com` on port: `80` during: `120` seconds.

---

## Attack Configuration

The script executes a continuous SYN flood using `hping3`:

| Option          | Purpose                          |
|-----------------|----------------------------------|
| -S              | Set TCP SYN flag                 |
| -p              | Target port                      |
| --flood         | Send packets as fast as possible |
| --rand-source   | Randomize source IP addresses    |
| --tcp-timestamp | Add TCP timestamp option         |

The attack runs for a defined duration using a timeout mechanism and is then gracefully stopped.

---

## Execution Behaviour

The attack generates a massive volume of half-open TCP connections, which can make other clients unable to access or use the site at all.

```mermaid
flowchart LR

    Attacker -->|SYN flood | Target
    Target -->|SYN-ACK (no future response)| Attacker
```

## Notes

The process is killed automatically after a period of time. **Not recommended to use `Ctrl + C` to kill the process** as the running script will also exit.

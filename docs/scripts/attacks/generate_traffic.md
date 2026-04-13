---
title: Dataset Generation
icon: material/database-export
---

# Dataset Generation

This script generates a **labeled dataset** for training and evaluating the AI-based threat detection model. It produces a realistic mix of benign and malicious traffic across all simulated protocols, calling some of the existing attack scripts in sequence.

It is compatible with both `topology.clab.yml` (full) and `topology_reduced.clab.yml` (reduced). Optional nodes from the full topology are automatically detected at runtime and skipped if absent.

---

## Script

Location:

> `scripts/attacks/generate_traffic.sh`

Basic usage:

```bash
sudo sh scripts/attacks/generate_traffic.sh
```

The script also supports the `-n` flag to integrate with the attack menu system:

```bash
# Returns: [X] Dataset generation | Traffic + Attacks
sh scripts/attacks/generate_traffic.sh -n
```

---

## Topology Compatibility

At startup, the script checks which containers are currently running and prints a summary:

```
  Required devices:
  [+] clab-virtual-env-attacker       (kali)
  [+] clab-virtual-env-benign         (olivia)
  [+] clab-virtual-env-pc_vlan50_1    (alice)
  [+] clab-virtual-env-pc_vlan60_1    (emma)
  [+] clab-virtual-env-pc_admin       (lois)

  Optional devices (full topology only):
  [-] clab-virtual-env-pc_vlan50_2    (barry)  <-- not found, commands will be skipped
  [-] clab-virtual-env-pc_vlan60_2    (clark)  <-- not found, commands will be skipped
```

Commands for `barry` and `clark` are skipped when the reduced topology is active. No manual changes are needed.

---

## Session Phases

The script runs the following phases in order:

| Phase | Type   | Description                                                          |
|-------|--------|----------------------------------------------------------------------|
| 1     | Benign | Normal base traffic: DNS, web browsing, and email in both directions |
| 2     | Attack | Port scanning - `port_scanning.sh`                                   |
| 3     | Benign | Normal traffic after the scan completes                              |
| 4     | Attack | DoS SYN flood - `dos_syn_flood_hping3.sh`                            |
| 5     | Attack | SSH brute force - `ssh_bruteforce_hydra.sh`                          |
| 6     | Attack | SMTP recon + IMAP brute force - `smtp _recon_abuse.sh`               |
| 7     | Benign | Normal traffic                                                       |

### Normal traffic (phases 1, 3, 7)

Benign traffic covers all simulated protocols that traverse the network to produce a realistic base:

- **DNS** - internal nodes query `internet.com` via the enterprise DNS resolver.
- **HTTP** - enterprise users browse `internet.com`; external nodes browse `enterprise.com`.
- **SMTP / IMAP** - all available enterprise users send an email to `olivia@internet.com`; olivia replies to alice; alice replies back.

### Attacks (phases 2, 4, 5, 6)

Each attack phase delegates directly to the corresponding script in `scripts/attacks/`. Refer to those pages for full details on tools, flags, and observed effects:

- [Port Scanning](port_scanning.md)
- [TCP SYN Flood](dos_syn_flood_hping3.md)
- [SSH Brute Force](ssh_bruteforce_hydra.md)
- [SMTP Recon + Relay Abuse](smtp_recon_abuse.md)

---

## Output

At the end of the run, the script prints the commands to extract or clear the log:

```bash
# Copy eve.json to the host
docker cp clab-virtual-env-logwatch:/var/log/suricata/eve.json ./ml/eve_$(date +%Y%m%d_%H%M%S).json

# Clear the log before the next run
docker exec clab-virtual-env-logwatch sh -c '> /var/log/suricata/eve.json'
```

!!! tip "Multiple runs"
    Clear `eve.json` before each run to keep sessions cleanly separated.

---
title: Dataset Generation
icon: material/database-export
---

# Dataset Generation

These scripts script generates a **labeled dataset** for training and evaluating the AI-based threat detection model. They produce realistic flows across all simulated protocols that traverse the network and are compatible with both `topology.clab.yml` (full) and `topology_reduced.clab.yml` (reduced). Optional nodes from the full topology are automatically detected at runtime and skipped if absent.

Three scripts are available depending on what kind of data is needed:

| Script                                       | Purpose                                                |
|----------------------------------------------|--------------------------------------------------------|
| [`generate_benign.sh`](#generate_benignsh)   | Benign traffic only; for training the normal baseline |
| [`generate_attacks.sh`](#generate_attackssh) | Attacks only; for training the malicious class        |
| [`generate_traffic.sh`](#generate_trafficsh) | Both combined; for benchmark and validation           |

All three live in `scripts/attacks/` and integrate with the attack menu system via the `-n` flag.

---

## Topology Compatibility

At startup, all three scripts check which containers are currently running and print a summary:

```
  Required devices:
  [+] clab-virtual-env-attacker       (kali)
  [+] clab-virtual-env-benign         (olivia)
  [+] clab-virtual-env-pc-vlan50-1    (alice)
  [+] clab-virtual-env-pc-vlan60-1    (emma)
  [+] clab-virtual-env-pc-admin       (lois)

  Optional devices (full topology only):
  [-] clab-virtual-env-pc-vlan50-2    (barry)  <-- not found, commands will be skipped
  [-] clab-virtual-env-pc-vlan60-2    (clark)  <-- not found, commands will be skipped
```

Commands for `barry` and `clark` are skipped when the reduced topology is active. No manual changes are needed.

---
 
## `generate_benign.sh`
 
Generates **benign traffic only**. Use this to generate the normal or expected behavior for the training of the dataset.
 
Location:
 
> `scripts/attacks/generate_benign.sh`
 
```bash
sudo sh scripts/attacks/generate_benign.sh
```
 
### Phases
 
| Phase | Description                                                                                     |
|-------|-------------------------------------------------------------------------------------------------|
| 1     | Normal baseline: DNS queries, web browsing in both directions, email exchange between all users |
| 2     | Mid-session normal: additional HTTP and email flows                                             |
| 3     | Final traffic: DNS queries and end-of-day emails                                                |
 
### Normal traffic coverage

Benign traffic covers all simulated protocols that traverse the network to produce a realistic base:

- **DNS:** internal nodes query `internet.com` via the enterprise DNS resolver.
- **HTTP:** enterprise users browse `internet.com`; external nodes browse `enterprise.com`.
- **SMTP / IMAP:** all available enterprise users (alice, emma, lois, and optionally barry and clark) send an email to `olivia@internet.com`. Olivia replies to alice, and alice replies back.

---
 
## `generate_attacks.sh`
 
Generates **attacks only**. Use this to build the malicious events of the training dataset.
 
Location:
 
> `scripts/attacks/generate_attacks.sh`
 
```bash
sudo sh scripts/attacks/generate_attacks.sh
```
 
### Phases
 
| Phase | Description                                           |
|-------|-------------------------------------------------------|
| 1     | Port scanning: `port_scanning.sh`                     |
| 2     | DoS SYN flood: `dos_syn_flood_hping3.sh`              |
| 3     | SSH brute force: `ssh_bruteforce_hydra.sh`            |
| 4     | SMTP recon + IMAP brute force: `smtp _recon_abuse.sh` |


### Attacks

Each attack phase delegates directly to the corresponding script in `scripts/attacks/`. Refer to those pages for full details on tools, flags, and observed effects:
 
- [Port Scanning](port_scanning.md)
- [TCP SYN Flood](dos_syn_flood_hping3.md)
- [SSH Brute Force](ssh_bruteforce_hydra.md)
- [SMTP Recon + Relay Abuse](smtp_recon_abuse.md)

---

## `generate_traffic.sh`
 
Generates **benign and malicious traffic combined**. Use this as a benchmark session to validate that the trained model can distinguish both classes in a realistic mixed scenario.
 
Location:
 
> `scripts/attacks/generate_traffic.sh`
 
```bash
sudo sh scripts/attacks/generate_traffic.sh
```

### Phases

| Phase | Type   | Description                                                          |
|-------|--------|----------------------------------------------------------------------|
| 1     | Benign | Normal base traffic: DNS, web browsing, and email in both directions |
| 2     | Attack | Port scanning - `port_scanning.sh`                                   |
| 3     | Benign | Normal traffic after the scan completes                              |
| 4     | Attack | DoS SYN flood - `dos_syn_flood_hping3.sh`                            |
| 5     | Attack | SSH brute force - `ssh_bruteforce_hydra.sh`                          |
| 6     | Attack | SMTP recon + IMAP brute force - `smtp _recon_abuse.sh`               |
| 7     | Benign | Normal traffic                                                       |

---

## Output

At the end of every run, each script prints the commands to extract or clear the log. The suggested filenames reflect the script used:
 
```bash
# generate_benign.sh
docker cp clab-virtual-env-logwatch:/var/log/suricata/eve.json ./ml/data/eve_benign_$(date +%Y%m%d_%H%M%S).json
 
# generate_attacks.sh
docker cp clab-virtual-env-logwatch:/var/log/suricata/eve.json ./ml/data/eve_attacks_$(date +%Y%m%d_%H%M%S).json
 
# generate_traffic.sh
docker cp clab-virtual-env-logwatch:/var/log/suricata/eve.json ./ml/data/eve_$(date +%Y%m%d_%H%M%S).json
```
 
Clear `eve.json` before each run to keep sessions cleanly separated:
 
```bash
docker exec clab-virtual-env-logwatch sh -c '> /var/log/suricata/eve.json'
```
 
!!! tip "Multiple runs"
    Running each script several times and merging the resulting files increases dataset size and may lead to generalisation on the ML model.

At the end of the run, the script prints the commands to extract or clear the log:

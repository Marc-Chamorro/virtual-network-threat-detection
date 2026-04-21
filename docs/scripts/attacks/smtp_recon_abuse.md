---
title: SMTP Recon + Relay Abuse
icon: material/email-alert-outline
---

# SMTP Recon + Relay Abuse

This scenario performs a multi-phase **mail server reconnaissance and abuse** attack against the enterprise mail infrastructure, combining several tools to progressively escalate from information gathering to credential theft.

---

## Attack Script

Location:
> `scripts/attacks/smtp_recon_abuse.sh`

Basic usage:

```bash
./scripts/attacks/smtp_recon_abuse.sh clab-virtual-env-attacker
```

With explicit parameters:

```bash
./scripts/attacks/smtp_recon_abuse.sh clab-virtual-env-attacker enterprise.com 25 143
```

| Parameter            | Description                            | Default                |
|----------------------|----------------------------------------|------------------------|
| `attacker-container` | Container executing the attack         | required               |
| `target`             | Target hostname or IP                  | `enterprise.com`       |
| `smtp-port`          | SMTP port                              | `25`                   |
| `imap-port`          | IMAP port for the brute force phase    | `143`                  |
| `mail-to`            | Recipient address for the spoofed mail | `alice@enterprise.com` |
| `mail-from`          | Spoofed sender address                 | `ceo@enterprise.com`   |

---

## Attack Phases

### Phase 1 - Service Fingerprinting

`nmap` retrieves the SMTP banner and enumerates all commands the server supports by issuing an `EHLO` probe. This reveals server software, version, and advertised extensions such as `AUTH` and `STARTTLS`.

Tools: `smtp-commands`, `smtp-ntlm-info` NSE scripts.

### Phase 2 - Mailbox Enumeration

Three SMTP mechanisms are used to discover valid mailbox addresses on the server:

| Method    | Description                                                            |
|-----------|------------------------------------------------------------------------|
| `VRFY`    | Directly asks the server to verify a mailbox address                   |
| `EXPN`    | Requests expansion of a mailing list alias                             |
| `RCPT TO` | Attempts to address a test message; works even when `VRFY` is disabled |

Valid usernames discovered here can be fed into Phase 5 or used in phishing campaigns.

Tool: `smtp-enum-users` NSE script.

### Phase 3 - Open Relay Test

An open relay accepts and forwards mail for any sender/recipient combination without authentication. This would allow the attacker to send spoofed mail through the enterprise server, causing outbound messages to appear to originate from a trusted enterprise IP and potentially bypass spam filters on external recipients.

The `smtp-open-relay` NSE script tests 16 different `FROM`/`TO` relay combinations automatically.

### Phase 4 - Spoofed Email Delivery

`swaks` (Swiss Army Knife for SMTP) sends a fully crafted email with a controlled sender address, simulating a spear-phishing message that appears to originate from a trusted internal account such as a department head or executive.

```text
FROM: ceo@enterprise.com
TO:   alice@enterprise.com
Subject: Urgent: Please review attached report
```

Tool: `swaks`

### Phase 5 - IMAP Credential Brute Force

`hydra` attempts to authenticate against the IMAP service using wordlists composed of usernames common in this environment and typical weak passwords. Any valid credentials are written to `/tmp/imap_found.txt` inside the attacker container.

Tool: `hydra` with `imap://` target protocol.

---

## Observed Effects

- **Phase 1–3:** nmap scan traffic appears in Suricata and records as connections to port 25
- **Phase 4:** The spoofed message is delivered to Alice's mailbox on the enterprise mail server and is visible when running `mutt` on `pc-vlan50-1`
- **Phase 5:** Failed IMAP authentication attempts appear as repeated connection events to port 143 in the flow logs, with a successful authentication visible at the end if valid credentials are found

!!! note "Mail service credentials"
    In this laboratory environment, each user's password is equal to their username (e.g. `alice` / `alice`). See [Mail Service](../../services/mail.md) for details.

!!! note "Open relay behaviour"
    The enterprise Postfix configuration uses `mynetworks = 127.0.0.1/32, 192.168.0.0/16`, which means it will only relay mail from trusted internal networks. Connections from the attacker (external network) will be rejected by the relay test, which is the expected and realistic result.

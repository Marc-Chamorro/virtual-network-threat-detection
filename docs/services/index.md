---
title: Services Overview
icon: material/application-settings
---

# Application Services

This section documents **application-level services** deployed within the laboratory.

Unlike core network services (DHCP, DNS), these services:
- Operate at higher layers
- Are workload-oriented
- Primarily used to generate realistic traffic
- Are intentionally simple and minimal.

---

## Scope of Application Services

Application services in this project are used to:

- Simulate real client–server interactions
- Generate observable traffic patterns

!!! note
    Services are deployed for realism and traffic generation, not functionality richness.

---

## Purpose and Design

The services integrated into the environment are designed to be minimal and predictable, maximizing focus on security monitoring and traffic analysis.

<div class="grid cards" markdown>

-   :material-web:{ .lg .middle } **WEB (HTTP)**

    ---

    Standard Nginx server providing basic web traffic on Port 80.
    [View Details](./web.md)

-   :material-ssh:{ .lg .middle } **SSH (Secure Shell)**

    ---

    Remote access simulation for administrative tasks and credential abuse scenarios.
    [View Details](./ssh.md)

-   :material-file-transfer:{ .lg .middle } **FTP (File Transfer)**

    ---

    Unencrypted file management via Port 21, featuring user isolation and chroot jails.
    [View Details](./ftp.md)

-   :material-email-outline:{ .lg .middle } **MAIL (SMTP/IMAP)**

    ---

    Realistic hub-and-spoke infrastructure for enterprise email exchange.
    [View Details](./mail.md)

</div>

---

## Design Principles

Application services follow these principles:

All application services follow these core technical requirements:

- **Minimal Configuration:** Optimized to use few resources while maintaining fidelity.
- **Predictability:** Clearly defined traffic patterns for easier rule creation.
- **Transparency:** Security features like TLS are intentionally disabled to facilitate clear traffic inspection and learning.
- **Decoupled Logic:** Most services are hosted on the `server_vntd` image and enabled via environment variables.

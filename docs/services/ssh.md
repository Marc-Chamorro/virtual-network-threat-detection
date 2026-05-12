---
title: SSH Service
icon: material/ssh
---

# SSH Service

The SSH service provides a mechanism for executing remote commands and simulate administration connections. It is intentionally configured with weak security settings to support credential abuse and brute-force experimentation.

---

## Implementation Details

The service is based on **OpenSSH Server** and is managed via environment variables in the container entrypoint file.

### Activation

The SSH service is enabled only if the following environment variable is set:

```yml
env:
    SSH_SERVER: 1
```

If this variable is absent or has any other value different than 1, the Nginx process will not initialize.

!!! note
    This allows the same container image to be reused with or without SSH enabled.

### Deployment Status

In the default provided topology, the SSH service is active *(on the containers using the `server_vntd` image)*:

- `dmz-server`: Internal organization website.
- `internet-server`: External public website simulation.
- `internal-server`: Interenal organization service provider.

### Default Credentials

When the SSH service is enabled, a dedicated user account is created automatically.

| Parameter | Value  |
|-----------|--------|
| Username  | `vntd` |
| Password  | `pswd` |

These credentials are defined directly in the startup script.

!!! warning "Credentials"
    These credentials are intentionally weak. They exist solely for lab and testing purposes.

---

## User and Authentication Configuration

At startup, the following actions are performed:

1. A new user (`vntd`) is created.
2. A password is assigned using chpasswd.
3. SSH is explicitly configured to:
    - Allow password authentication.
    - Allow root login.

Additionally, a user-specific (`vntd`) SSH configuration block is appended to ensure password access for the created user.

---

## SSH Behavior

Once configured, the SSH service is started using the system service manager:

```bash
service ssh start
```

SSH traffic:

- Uses TCP port 22.
- Traverses firewall and routing policies.

!!! tip "Security"
    Repeated failed SSH attempts are useful for simulating brute-force or credential abuse scenarios.

---

## How to use

The Alpine client images include a SSH Client, which is used to interact with the SSH service. To connect to the SSH service, use the following command:

```bash
ssh vntd@<name or address>
```

!!! info "IP"
    IP addresses can be used if the domain names are unknown or a DNS service is not available.
    By default, all servers have a DNS-resolvable hostname.

When prompted, enter the default password:

```bash
pswd
```

The available hostnames are defined in the DNS configuration:

- [DNS Names Assignment](../network-services/dns/config.md)

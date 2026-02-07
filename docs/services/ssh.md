# SSH Service

This document describes the **SSH service implementation** used in the laboratory.

The SSH service is intentionally simple and is enabled conditionally at container startup.

---

## Service Activation

The SSH service is enabled only if the following environment variable is set:

```yml
env:
    SSH_SERVER: 1
```

If the variable is not set (or set to any other value), the SSH service is not started.

!!! note
    This allows the same container image to be reused with or without SSH enabled.

---

## Default Credentials

When the SSH service is enabled, a dedicated user account is created automatically.

| Parameter | Value  |
|-----------|--------|
| Username  | `vntd` |
| Password  | `pswd` |

These credentials are defined directly in the startup script.

!!! warning
    These credentials are intentionally weak.
    They exist solely for lab and testing purposes.

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

!!! tip
Repeated failed SSH attempts are useful for simulating brute-force or credential abuse scenarios.

# Services

This section documents **application-level services** deployed within the laboratory.

Unlike core network services (DHCP, DNS), these services:
- Operate at higher layers
- Are workload-oriented
- Primarily used to generate realistic traffic

They are intentionally simple and minimal.

---

## Scope of Application Services

Application services in this project are used to:

- Simulate real client–server interactions
- Generate observable traffic patterns

!!! note
    Services are deployed for realism and traffic generation, not functionality richness.

---

## Documented Services

Currently documented services:

| Service | Purpose |
|------|--------|
| [SSH](./ssh.md) | Remote access and command execution |
| [Web](./web.md) | HTTP-based application traffic |

Each service is documented independently, but they share common design principles.

---

## Design Principles

Application services follow these principles:

- **Minimal Configuration**
- **Predictable Behavior**
- **Clear Traffic Patterns**
- **Easy Inspection**

!!! info
    Additional services can be added following the same documentation structure.

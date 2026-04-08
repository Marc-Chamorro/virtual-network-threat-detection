---
title: Dockerfile Standards
icon: material/file-code
---

# Dockerfile Standards

To maintain consistency across the laboratory environment, all custom images adhere to a strict set of guidelines. These standards ensure that images are lightweight, non-interactive during build, and persistent during runtime.

---

## Design Considerations

### 1. Non-Interactive Environment

To prevent build failures caused by package managers requesting user input, images are configured for non-interactive environments.

```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

### 2. Image Optimization (Cleanup)

To keep image sizes minimal, cached package lists are removed within the same RUN instruction once the software is installed. This prevents the cache from being stored unnecessarily.

**Pattern:**

```Dockerfile
RUN apt-get update && apt-get install -y \
    <package_name> \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

> This prevents the cache from being stored unnecessarily.

### 3. Service Persistence

In a standard Docker environment, a container exits as soon as its main process finishes. However, a network node (like a router) must stay alive even if it's doing nothing but listening.

If no specific service (like a web server) keeps the container occupied, use:

```Dockerfile
CMD ["sleep", "infinity"]
```

---

## Standard Package Sets

Most container images (routers, switches, endpoints) include a set of network diagnostic tools to facilitate debugging during labs.

### Network Diagnostic Tools

- `iproute2` (`ip`): Modern interface configuration.
- `net-tools` (`ifconfig`, `netstat`): Controlling network subsystem.
- `iputils-ping` (`ping`): Connectivity testing.
- `traceroute`: Path analysis.
- `tcpdump`: Packet capture.
- `curl`: HTTP connectivity testing.

### Network Control

- `procps`: Provides sysctl for enabling IP forwarding.
- `iptables`: Packet filtering.

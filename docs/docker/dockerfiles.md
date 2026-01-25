# Dockerfile Standards

To maintain consistency across the laboratory environment, all custom images adhere to a strict set of guidelines. These standards ensure that images are lightweight, non-interactive during build, and persistent during runtime.

## Design Considerations

### 1. Non-Interactive Environment

Debian and Ubuntu-based images often prompt for timezone or keyboard configuration during installation. This breaks automated builds. We explicitly disable this:

```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

### 2. Image Cleanup
To keep the footprint small, package lists (apt cache) are removed in the same RUN instruction as the installation. This prevents the cache from being committed to the image layer.

Pattern:

Dockerfile
RUN apt-get update && apt-get install -y \
    <package_name> \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

### 3. Service Persistence (The "Sleep Infinity" Pattern)
In a standard Docker environment, a container exits as soon as its main process finishes. However, a network node (like a router) must stay alive even if it's doing nothing but listening.

If no specific service (like a web server) keeps the foreground occupied, we use:

Dockerfile
CMD ["sleep", "infinity"]

---

## Standard Package Sets
Most "device" images (routers, switches, endpoints) include a baseline set of network diagnostic tools to facilitate debugging during labs.

### Network Diagnostic Tools

iproute2 (ip): Modern interface configuration.

net-tools (ifconfig, netstat): Legacy tools, often required by older scripts.

iputils-ping (ping): Connectivity testing.

traceroute: Path analysis.

tcpdump: Packet capture.

curl: HTTP connectivity testing.

### Network Control

procps: Provides sysctl for enabling IP forwarding.

iptables: Packet filtering.
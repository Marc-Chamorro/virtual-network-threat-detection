---
title: Web Service
icon: material/web
---

# Web Service

The web service implements **basic HTTP traffic** simulation with minimal configuration. It is primarily used to test web-based detection, logging, and traffic classification.

---

## Technical Implementation

The service utilizes **Nginx**, which is pre-installed in the server image.

### Activation

The service is enabled only by setting the following environment variable in the topology file:

```yml
env:
    WEB_SERVER: 1
```

If this variable is absent or has any other value different than 1, the Nginx process will not initialize.

!!! note "Activation Through Variables"
    This allows a single container image to serve multiple roles depending on runtime configuration.

### Deployment Status

In the default provided topology, the web service is active *(on the containers using the `server_vntd` image)*:

- `dmz-server`: Internal organization website.
- `internet-server`: External public website simulation.

---

## Served Content

When enabled, the service creates a single static page:

```text
Hello from Nginx on the web server
```

This content is written directly to:
```text
/var/www/html/index.nginx-debian.html
```

There are:
- No dynamic pages
- No authentication
- No application logic

---

## Web Behavior

The web server is started using the system service manager:

```bash
service nginx start
```

Nginx runs in the background using default settings.

!!! info "Traffic within the enterprise"
    Web traffic uses standard TCP port 80 and must traverse firewall and routing policies to reach the destination floor.

!!! info
    Due to its simplicity, this service is ideal for testing HTTP-based detection, logging, and traffic classification.

---

## How to use

To generate HTTP traffic against the web service, use a simple HTTP client such as `curl` frp, any client workstation or external node:

```bash
curl http://<hostname>
curl <hostname>
```

!!! info "IP"
    IP addresses can also be used if the domain names are unknown or a DNS service is not available.
    By default, all servers have a DNS-resolvable hostname.

If the service is running correctly, the service will respond with a message.

The available hostnames are defined in the DNS configuration:
- [DNS Names Assignment](../network-services/dns/config.md)

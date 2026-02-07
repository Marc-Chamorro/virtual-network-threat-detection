# Web Service

This document describes the **web service implementation** used in the laboratory.

The service is designed to generate **basic HTTP traffic** with minimal configuration.

## Service Activation

The web service is enabled only if the following environment variable is set:

```yml
env:
    WEB_SERVER: 1
```

If the variable is not set, the web server is not started.

!!! note
    This allows a single container image to serve multiple roles depending on runtime configuration.

---

## Web Server Software

The service uses **Nginx**, installed as part of the container image.

No advanced configuration is applied.

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

## Web Behavior

The web server is started using the system service manager:

```bash
service nginx start
```

Nginx runs in the background using default settings.

Web traffic:
- Uses HTTP (TCP port 80)
- Traverses firewall and routing policies.

!!! info
    Due to its simplicity, this service is ideal for testing HTTP-based detection, logging, and traffic classification.

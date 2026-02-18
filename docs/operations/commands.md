---
title: Operational Commands Reference
icon: material/fontawesome-solid-code
---

# Operational Commands Reference

This document provides a repository of useful commands for managing, troubleshooting, and interacting with the nodes in the VNTD laboratory.

---

## Container Management

These commands are executed from the **host machine** to control the virtual environment.

- **View Device Logs:** Check the output and initialization errors for a specific node:
```sh
docker logs clab-virtual-env-internal_server
```

- **Connect to a Device:** Open a terminal inside a running node:
```sh
docker exec -it clab-virtual-env-pc_vlan50_1 bash
```

---

## Services

To view the services running on a concrete device, use:

```sh
service --status-all
```

```sh
ps aux
```

---

## Traffic Inspection Tools

### tcpdump

Use `tcpdump` to capture and analyze packets on a specific interface. This is critical for validating that the **DHCP Relay** or **Firewall** is forwarding traffic correctly.

- **Monitor DHCP Traffic:** In which `port` is the physical port to analyze. For this example, DHCP traffic can be viewed to detect any possible related issues given changes are made and the service is no longer working as intended.

```sh
tcpdump -i <port> -f 'port 67 or port 68'
```

---

## Connectivity and Web Verification

Test if web services are reachable and serving content through the network policies.

### Web Service Check

```sh
# Internal DMZ Website
curl http://enterprise.local

# External ISP Website
curl http://internet.com
```
> *Expected output: "Hello from Nginx on the web server"*

---

## DHCP Troubleshooting

To request an IP address again from a client device with access to the DHCP server:

```sh
dhcpcd -4 -d eth1
```

---

## DNS Troubleshooting

Tools to verify the name resolution service between the enterprise network and the internet.

### DNS Infrastructure

| Zone             | DNS Known IP Addresses       |
|------------------|------------------------------|
| **Internal DNS** | 192.168.10.10, 192.168.40.10 |
| **External DNS** | 172.16.100.100, 172.16.30.2  |

### Resolution Diagnostic Tools

```sh
# Which DNS to query
cat /etc/resolv.conf
```

```sh
# Query DNS records for a specific name
nslookup enterprise.local
nslookup 192.168.10.10
```

```sh
# More structured and detailed output
dig www.enterprise.local
```

#### Example Output

```
pc_enterprise:/# nslookup enterprise.local
Server:		192.168.10.10
Address:	192.168.10.10#53

Name:	enterprise.local
Address: 192.168.10.10
```

```
pc_enterprise:/# nslookup enterprise.com
Server:		192.168.10.10
Address:	192.168.10.10#53

Name:	enterprise.com
Address: 192.168.10.10
```

```
pc_enterprise:/# nslookup internet.com
Server:		192.168.10.10
Address:	192.168.10.10#53

Name:	internet.com
Address: 172.16.100.100
```

---

## Mutt

End-user systems use the Mutt mail client for sending and retrieving emails.

- **Launch:** Type in the terminal:
```sh
mutt
```
- **Editor Usage:** When setting up mail, use the built-in editor. To save changes and exit the editor, use the command `:wq`.
- **Note:** The client does not detect new emails in real-time. You must exit and restart the program to refresh the inbox.

---

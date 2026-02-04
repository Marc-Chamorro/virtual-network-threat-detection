# Traffic Flows

This page documents the **expected traffic flows** within the architecture the security logic enforced by the network devices. Understanding these flows is critical for debugging and validating the network.

## Routing & Connectivity Logic

The environment uses a hybrid routing model to ensure internal isolation and external accessibility.

### External Routing (OSPF)

The `router_enterprise` uses OSPF to communicate with the Internet core.
- **Advertisement:** It announces the public address (`172.16.30.2/30`).
- **Static Routes:** To ensure traffic reaches internal VLANs, the router has static routes pointing all `192.168.0.0/16` traffic to the Firewall (`192.168.0.2`).

### Internal Gateway

- **Firewall as Gateway:** The firewall acts as the gateway for all VLANs.
- **Default Route:** The firewall sends all unknown traffic to the Enterprise Router (`192.168.0.1`).

## Security Policies (iptables)

The Firewall implements a **Default DROP** policy for all INPUT and FORWARD packets. Only explicit flows are permitted.

### Core Firewall Rules

- **Stateful Inspection:** All established and related traffic is allowed via `conntrack`.
- **Management:** ICMP (Ping) is allowed from the enterprise subnets to the firewall itself for diagnostic and testing purposes.

### Inter-Zone Communication

| Source          | Destination             | Permitted Traffic                               |
|-----------------|-------------------------|-------------------------------------------------|
| Admin (VLAN 30) | Any                     | Unrestricted Full Access                        |
| Users (50/60)   | Internet, DMZ, Services | General Outbound and DHCP In/Out DHCP requests  |
| Services (40)   | Admin, Users            | General Outbound and DHCP In/Out DHCP responses |
| Monitoring (20) | -                       | None                                            |
| DMZ (10)        | Internet                | DNS queries only                                |

Traffic between devices from the same VLAN is permitted.

## Specific Protocol Flows

### Inbound (DNAT)

Accessing the DMZ Server (192.168.10.10) from Internet consists of a two-step process:
1. **Router Enterprise:** Translates incoming traffic from port 80 to the Firewall.
2. **Firewall:** Translates port 80 (HTTP) requests to the DMZ Server.

### Outbound (SNAT)

Accessing the Internet from within the network consists of:
1. **Firewall:** Ensures communication policies are met, and if so, redirects traffic to the Router.
2. **Router Enterprise:** Allows communication with the outside world through Masquerade.

### DHCP Relay Mechanism

Since the DHCP Server is in VLAN 40 and clients are in VLAN 50/60, the firewall performs a relay:
1. **Client:** Broadcasts DHCP DISCOVER on the bridge (br-vlan50/60).
2. **Firewall:** INPUT rule accepts UDP 67. The isc-dhcp-relay service forwards this to 192.168.40.10.
3. **Server:** Responds to the Firewall. OUTPUT rule allows the relay to send the IP back to the client.

### DNS

The DMZ server provides DNS service to individuals within the enterprise network. Devices using DHCP will receive the DNS address automatically upon IP assignment. This service responds to the name addresses referencing the internal server.

Given the situation an unknown address is received, the DNS forwards the request to the DNS located on the Internet Server:
1. **Client:** Requests address for a specific domain name.
2. **DMZ:** Either answers or redirects the response to the external DNS.
3. **Internet Server:** Responds to the requested addresses.

### Traffic Mirroring (IDS)

To provide network visibility without interfering with traffic, the firewall uses the TEE function:
- **Action:** Every packet entering eth1 (Internet-facing) is cloned.
- **Target:** Sent to 192.168.20.10 (IDS).
- **Restriction:** The IDS is strictly prohibited from sending traffic back into the network.

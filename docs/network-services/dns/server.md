# DNS Server Configuration

This document describes the **configuration and behavior** of the DNS server used in the VNTD lab.

The configuration focuses on clarity, explicit behavior, and ease of debugging.

## Usage

To make use of the DNS service included in the `server_vntd` container, proceed with the following steps:

1. Set as environment variables (`env`) the following elements in the desired container using the `server_vntd` image: 

    - DNS_SERVER - Enable the DNS service (any value other rather than 1 prevents the service from starting).

```yml
env:
    DNS_SERVER: 1
```

2. Bind the configuration file required for the service to work:

    - `dnsmasq.conf` - DNS configuration, name resolution, address assigned.

!!! note
    The DNS server from the enterprise uses a different `.conf` file adapted to its needs. The one for the internet server provides a '*simpler*' format.

```yml
binds:
    - ./config/server/dns/enterprise/dnsmasq.conf:/etc/dnsmasq.conf
```

## Service Placement

The DNS server runs on two specific devices:

- **Internal Server**
    - **Node:** `dmz_server`
    - **VLAN:** 10
    - **IP Address:** `192.168.10.10`
- **Internet Server**
    - **Node:** `internet_server`
    - **VLAN:** Does not belong to any VLAN
    - **IP Address:** `172.16.100.100`

Such nodes may also host other services, but the DNS is isolated from others.

## DNS Software

The service is implemented using:

- **`dnsmasq`**

The server is to be bound to a specific port: `53`. Most configuration documentation can be found within the same `.conf` file through comments.

All DNS configuration files are stored under the project `config/` directory and mounted into the container at runtime.

!!! warning
    Changes made inside the running container are **not persistent** and will be lost on redeployment.

## DNS Configuration (`internet_server`)

**Names Defined:** Resolves names to addresses.
| Name                  | Address        |
|-----------------------|----------------|
| `internet.com`        | 172.16.100.100 |
| `www.internet.com`    | 172.16.100.100 |
|                       |                |
| `enterprise.com`      | 172.16.30.2    |
| `www.enterprise.com`  | 172.16.30.2    |

**PTR Defined:** Resolves addresses to names.
| Address             | Name             |
|---------------------|------------------|
| 172.16.100.100      | `internet.com`   |
| 172.16.30.2         | `enterprise.com` |

This configuration allows clients to communicate with the Internet Server and the DMZ Enterprise Server.

!!! note
    Although the 172.16.30.2 address belongs to the router, all traffic is redirected to the DMZ server.

**Forwarding:** The server does not forward DNS requests to any outside network. If the name or address is unknown, the service won't be able to respond.

## DNS Configuration (`dmz_server`)

**Names Defined:** Resolves names to addresses.
| Name                        | Address       |
|-----------------------------|---------------|
| `enterprise.local`          | 192.168.10.10 |
| `www.enterprise.local`      | 192.168.10.10 |
|                             |               |
| `enterprise.com`            | 192.168.10.10 |
| `www.enterprise.com`        | 192.168.10.10 |
|                             |               |
| `internal.enterprise.local` | 192.168.40.10 |

The DMZ Server also contains name resolution for the `.com` pointing to itself. This allows users to connect to the DMZ just as external users/clients would but removes the need to leave the network.

**PTR Defined:** Resolves addresses to names.
| Address         | Name                        |
|-----------------|-----------------------------|
| 192.168.10.10   | `enterprise.local`          |
| 192.168.10.10   | `enterprise.com`            |
| 192.168.40.10   | `internal.enterprise.local` |

This configuration allows clients to communicate with the Internet Server and the DMZ Enterprise Server (and the latter without leaving the network).

**Forwarding:** Given the situation where the server does *not* know the name or address, a request to the DNS located on the internet will be made in order to attempt to recover the requested address.

> server=172.16.100.100

From the internal network, through the **firewall's** point of view, only the server can communicate with any external DNS service.

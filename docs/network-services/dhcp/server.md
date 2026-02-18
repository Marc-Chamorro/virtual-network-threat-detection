---
title: DHCP Server Configuration
icon: material/database-settings
---

# DHCP Server Configuration

This document details the **configuration and behavior** of the provided DHCP server used in the VNTD lab.

The DHCP server is hosted on the `internal_server` node within the **Internal Services (VLAN 40)** zone.

---

## Service Activation

The service is powered by the **ISC DHCP Server** and runs on a dedicated internal service node. This placement ensures controlled access and avoids exposure to other zones or undesired external networks.

To make use of the service included in the `server_vntd` container, proceed with the following steps:

### 1. Topology

Set as environment variables (`env`) the following elements in the desired container using the `server_vntd` image: 

- DHCP_SERVER - Enable the service (any value other rather than 1 prevents the service from starting).
- IFACE - Selected interface.
- IP_ADDR - Address assigned to the interface.

!!! note "Consideration"
    These values do **not configure the device** or the DHCP service; **manual file configuration still needs to be done** if the user wants to change the service configuration. Instead, they are used for the `entrypoint.sh` script so it waits until the interface and address are assigned to initialize the service. If the service starts before the interface or address is assigned, the service won't start.

```yml
env:
    DHCP_SERVER: 1
    IFACE: "eth1"
    IP_ADDR: "192.168.40.10"
```

### 2. Configuration Files

Bind both configuration files required for the service to work:

- `dhcpd.conf` - Address pools and service configuration.
- `isc-dhcp-server` - Selected interface to operate on.

```yml
binds:
    - ./config/server/dhcp/dhcpd.conf:/etc/dhcp/dhcpd.conf
    - ./config/server/dhcp/isc-dhcp-server:/etc/default/isc-dhcp-server
```

---

## DHCP Software

The service is implemented using **`isc-dhcp-server`**. The server is to be explicitly bound to a single interface: `eth1`. This prevents the DHCP daemon from listening on unintended interfaces (even though in this scenario, all `internal_server` traffic is routed through the same interface).

Configuration is defined in:

- `/etc/default/isc-dhcp-server`
- `/etc/dhcp/dhcpd.conf`

All DHCP configuration files are stored under the project `config/server/dhcp` directory and mounted into the container at runtime.

!!! warning "Persistence"
    Changes made directly inside the running container are **not persistent** and will be lost on redeployment.

---

## Address Definitions

The server defines dedicated pools for each user VLAN in the `dhcpd.conf` file:

| VLAN   | Subnet          | IP Range             | Gateway      |
|--------|-----------------|----------------------|--------------|
| **40** | 192.168.40.0/24 | - (Declared only)    | 192.168.40.1 |
| **50** | 192.168.50.0/24 | 192.168.50.10 - .254 | 192.168.50.1 |
| **60** | 192.168.60.0/24 | 192.168.60.10 - .254 | 192.168.60.1 |

!!! important "Topology Declaration"
    It is necessary to declare the address of the network the DHCP device belongs to, even if it does not offer any service; otherwise, the service will not work.rt.

Clients receive as a part of their configurations the assignment of a default gateway and a DNS server address. This avoids manual client configuration and centralized configuration for ease of management.

!!! example "Configuration example"
    ``` conf
        subnet 192.168.50.0 netmask 255.255.255.0 {
            range 192.168.50.10 192.168.50.254;
            option routers 192.168.50.1;
            option subnet-mask 255.255.255.0;
            option broadcast-address 192.168.50.255;
        }
    ```

!!! example "Configuration example - Topology Declaration"
    ```conf
        subnet 192.168.40.0 netmask 255.255.255.0 {
        }
    ```

The DHCP can also be configured to provide a DNS address to the clients by making use of the following:

!!! example "Configuration example - Provide DNS"

    ``` conf
        option domain-name "enterprise.local";
        option domain-name-servers 192.168.10.10, 192.168.40.10;
    ```

!!! note "Global Configuration"
    DNS settings can be applied globally, regardless of the VLAN receiving the same DNS parameters.

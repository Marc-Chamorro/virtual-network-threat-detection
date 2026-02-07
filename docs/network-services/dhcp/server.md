# DHCP Server Configuration

This document details the **configuration and behavior** of the DHCP server used in the VNTD lab.

The server provides address assignment and network parameters to all user endpoints via the **firewall relay**.

---

## Usage

To make use of the DHCP service included in the `server_vntd` container, proceed with the following steps:

1. Set as environment variables (`env`) the following elements in the desired container using the `server_vntd` image: 

    - DHCP_SERVER - Enable the DHCP service (any value other rather than 1 prevents the service from starting).
    - IFACE - Selected interface.
    - IP_ADDR - Address assigned to the interface.

!!! note
    These values do not configure the device or the DHCP service; manual file configuration still needs to be done if the user wants to change the service configuration. Instead, they are used for the `entrypoint.sh` script so it waits until the interface and address are assigned to initialize the service. If the service starts before the interface or address is assigned, the service won't start.

```yml
env:
    DHCP_SERVER: 1
    IFACE: "eth1"
    IP_ADDR: "192.168.40.10"
```

2. Bind both configuration files required for the service to work:

    - `dhcpd.conf` - Address pools and service configuration.
    - `isc-dhcp-server` - Selected interface.

```yml
binds:
    - ./config/server/dhcp/dhcpd.conf:/etc/dhcp/dhcpd.conf
    - ./config/server/dhcp/isc-dhcp-server:/etc/default/isc-dhcp-server
```

---

## Service Placement

The DHCP server runs on a dedicated internal service node:

- **Node:** `internal_server`
- **VLAN:** 40 (Internal Services)
- **IP Address:** `192.168.40.10`

This placement ensures controlled access and avoids exposure to other zones or undesired external networks.

---

## DHCP Software

The service is implemented using:

- **ISC DHCP Server (`isc-dhcp-server`)**

The server is to be explicitly bound to a single interface: `eth1`. This prevents the DHCP daemon from listening on unintended interfaces (even though in this scenario, all `internal_server` traffic is routed through the same interface).

Configuration is defined in:

- `/etc/default/isc-dhcp-server`
- `/etc/dhcp/dhcpd.conf`

All DHCP configuration files are stored under the project `config/` directory and mounted into the container at runtime.

!!! warning
    Changes made directly inside the running container are **not persistent** and will be lost on redeployment.

---

## Address Pools

Dedicated address pools are defined for each user VLAN:

- **VLAN 50:** `192.168.50.0/24`
- **VLAN 60:** `192.168.60.0/24`

Each pool specifies a certain group of parameters, ensuring consistent behavior across all user floors:
- IP address range
- Subnet mask
- Default gateway (firewall)
- Broadcast address

---

### Example
``` conf
subnet 192.168.50.0 netmask 255.255.255.0 {
    range 192.168.50.10 192.168.50.254;
    option routers 192.168.50.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.168.50.255;
}
```

Additional DNS parameters:
- DNS server(s)
- Lease duration

---

### Example
``` conf
option domain-name "enterprise.local";
option domain-name-servers 192.168.10.10, 192.168.40.10;
```

!!! note
    DNS settings can be applied globally, regardless of the VLAN receiving the same DNS parameters.

!!! important
    It is necessary to declare the address of the network the DHCP device belongs to, even if it does not offer any service; otherwise, the service will not work.

- **Example:**
```conf
subnet 192.168.40.0 netmask 255.255.255.0 {
}
```

Clients receive as a part of their configurations the assignment of a default gateway and a DNS server address. This avoids manual client configuration and centralized configuration for ease of management.

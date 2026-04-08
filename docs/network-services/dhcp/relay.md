---
title: DHCP Relay Configuration
icon: material/bridge
---

# DHCP Relay Configuration

The **DHCP Relay** mechanism is essential for providing dynamic addressing in a segmented network where clients and the server reside in different Layer 3 domains. This mechanism allows forwarding all DHCP communication between zones. Without a relay, DHCP would fail by design.

The DHCP relay service is hosted on the `firewall` node.

---

## Service Activation

The service is powered by the **ISC DHCP Relay** and runs on the dedicated firewall node. As it runs on the **Central Firewall**, it serves as the default gateway for all VLANs and has direct interfaces in every segment, handling responses and forwarding DHCP traffic between clients and the server.

Considering it already enforces inter-VLAN policies, makes the firewall the optimal location for DHCP relaying.

To utilize the DHCP Relay service included in the `firewall_vntd` container, proceed with the following steps:

### 1. Topology

Set as environment variables (`env`) the following elements in the desired container using the `firewall_vntd` image: 

- DHCP_RELAY - Enable the service (any value other rather than 1 prevents the service from starting).

!!! note "Consideration"
    This setting also establishes the necessary firewall rules to allow DHCP traffic between VLANs.

```yml
env:
    DHCP_RELAY: 1
```

### 2. Configuration Files

Bind both configuration files required for the service to work:

- `startup.sh` - Required to start and set all firewall rules.
- `isc-dhcp-relay` - Interfaces to offer service and the interface connected with the DHCP service. Include the IP of the DHCP server.

```yml
binds:
    - ./config/firewall/enterprise/startup.sh:/startup.sh
    - ./config/firewall/enterprise/isc-dhcp-relay.conf:/etc/default/isc-dhcp-relay
exec:
    - sh /startup.sh
```

!!! note "Startup Script"
    The startup script **always** needs to be executed on the Firewall device to ensure traffic rules, VLANs and policies are enforced.

---

## DHCP Relay Software

The service is implemented using **`isc-dhcp-relay`**. The service has definesthe definition of where the requests should be sent and which interfaces to listen on. Such are defined like:

```conf
SERVERS="192.168.40.10"               # 1
INTERFACES="br-vlan50 br-vlan60 eth5" # 2
```

1. The IP address of the central DHCP server in VLAN 40.
2. The internal bridges for user floors and the interface connected to the services VLAN.

---

## Security Policies

The firewall must permit UDP traffic on ports 67 and 68 for the relay process to work. The `startup.sh` script includes rules to allow the firewall to process incoming petitions from user subnets and communicate with the server.

The relay does not ignore firewall filtering. All DHCP traffic is subject to all policies enforced.

!!! tip "Inspection"
    To debug DHCP transactions, use the following command on the firewall:
    ```sh
    tcpdump -i <interface> -f 'port 67 or port 68'
    ```

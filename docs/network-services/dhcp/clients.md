---
title: DHCP Client Behavior
icon: material/laptop
---

# DHCP Client Behavior

Clients in the VNTD environment are designed to simulate realistic enterprise endpoints using lightweight **Alpine Linux** images. These are designed to be minimal, automated, and representative of real enterprise endpoints.

---

## Client Scope

DHCP clients include:

- User workstations in VLAN 50.
- User workstations in VLAN 60.

---

## Service Activation

The service is powered by **DHCP Client** and runs on all `alpine_vntd` machines.

To utilize the DHCP client included in the end users devices, proceed with the following steps:

### 1. Topology

Set as environment variables (`env`) the following elements in the desired container using the `alpine_vntd` image: 

- DHCP_CLIENT - Starts the interface and waits for an address to be assigned on that specified interface.

!!! important "Interface"
    The interface chosen must be the same as the one used on the topology definition file to connect with other devices.

```yml
env:
    DHCP_CLIENT: 1
    IFACE: "eth1"
```

### 2. Configuration files

The only necessary bind required for the device to make use of the DHCP service is:

- `startup.sh` - Wakes up the interface, waits for an address to be assigned.

```yml
binds:
    - ./config/pc/startup.sh:/startup.sh
exec:
    - sh /startup.sh
```

---

## Automated Startup

Each client workstation (e.g., `pc-vlan50-1`) executes the `startup.sh` script upon launch to automate the network configuration process.

The script performs:

- Interface activation.
- DHCP request for IPv4 configuration.
- Automatic application of routing and DNS settings.

This ensures that clients are fully operational without manual intervention.

!!! example "Waiting for the DHCP process"
    If the DHCP provider doesn't start and offer service on time, the devices may stop asking. To solve this, simply make the device wait until the device obtains an address.

    ```bash
    # from labs/config/pc/startup.sh

    while true; do
        if dhcpcd -4 -w "$IFACE"; then
            break
        fi
        sleep 5
    done
    ```

---

## Applied Parameters

Once the ip assignment process is complete, the client automatically receives and applies:

- **IP Address and Mask**.
- **Default Gateway:** Points to the Firewall interface (e.g., `192.168.50.1`).
- **DNS Resolver:** In this case it points to the DMZ Server (`192.168.10.10`).

!!! important "Network Dependency"
    Client connectivity depends on:
    - Correct firewall relay configuration.
    - Active DHCP server.
    - Allowed DHCP traffic in firewall policies.
    If any of these components fail, clients will not obtain network access.

---

## Troubleshooting

If a client fails to obtain an IP, verify:

1. Connectivity between the clients and the server.
2. The firewall node has `DHCP_RELAY` enabled.
3. The `internal-server` is running and the DHCP service is active.
4. The L2 bridges on the firewall (`br-vlan50`, `br-vlan60`) are up and STP is disabled.

!!! question "Check IP"
    Clients can inspect their state using: `ifconfig`
    This tool is useful for understanding applied configuration.

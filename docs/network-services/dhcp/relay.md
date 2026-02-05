# DHCP Relay Configuration

This document explains how DHCP requests are **relayed** across VLAN boundaries using the firewall.

The relay mechanism is essential for enabling DHCP in a segmented network.

## Why DHCP Relay

DHCP clients use broadcast packets during address discovery.

In this architecture:
- User VLANs are isolated at Layer 3.
- Broadcast traffic cannot cross VLAN boundaries.
- The DHCP server is located in a different subnet.

A device is needed to forward all DHCP communication between zones. Without a relay, DHCP would fail by design.

### Relay Placement

The relay runs on the **firewall**, which:

- Has interfaces in all VLANs.
- Acts as the default gateway.
- Already enforces inter-VLAN policies.

This makes the firewall the optimal location for DHCP relaying.

## Usage

To utilize the DHCP Relay service included in the `firewall_vntd` container, proceed with the following steps:

1. Set as environment variables (`env`) the following elements in the desired container using the `firewall_vntd` image: 

    - DHCP_RELAY - Enable the DHCP Relay service (any value other rather than 1 prevents the service from starting).

!!! note
    This setting also establishes the necessary firewall rules to allow DHCP traffic between VLANs.

```yml
env:
    DHCP_RELAY: 1
```

2. Bind both configuration files required for the service to work:

    - `startup.sh` - Required to start and set all firewall rules.
    - `isc-dhcp-relay` - Interfaces to offer service and interface connected with the DHCP service. Include the IP of the DHCP server.

```yml
binds:
    - ./config/firewall/enterprise/startup.sh:/startup.sh
    - ./config/firewall/enterprise/isc-dhcp-relay.conf:/etc/default/isc-dhcp-relay
exec:
    - sh /startup.sh
```

!!! note
    The startup script always needs to be executed on the Firewall device to ensure traffic rules, VLANs and policies are enforced.

## Service Placement

The DHCP Relay service runs on a dedicated internal service node:

- **Node:** `firewall_vntd`
- **VLAN:** Manages all VLANs
- **IP Address:** the Gateway for all the VLANs

Ensures all VLANs, if desired, have access to the DHCP service.

## Implementation

The relay service is implemented using:

- **ISC DHCP Relay (`isc-dhcp-relay`)**

The service is configured to:

- Listen on user VLAN bridges.
- Forward requests to `192.168.40.10`.
- Handle responses and forward them back to clients.

## Packet Flow

The DHCP relay flow is as follows:

1. Client broadcasts `DHCPDISCOVER`.
2. Firewall accepts the packet.
3. Relay forwards it as unicast to the DHCP server.
4. Server replies to the firewall.
5. Firewall relays the response to the client.

## Security

Firewall rules ensure that:

- Only DHCP-related UDP traffic is processed.
- Relay traffic is limited to known interfaces.
- No direct client-to-server communication occurs.

!!! important
    The relay does not ignore firewall filtering. All DHCP traffic is subject to all policies enforced.

## Local Inspection Tools

The traffic can be inspected using:

- `tcpdump -i <port> -f 'port 67 or port 68'`

In which `port` is the physical port to analyze. This way, DHCP traffic can be viewed to detect any possible related issues given changes are made and the service is no longer working as intended.

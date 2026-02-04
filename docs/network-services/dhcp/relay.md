# DHCP Relay Configuration

This document explains how DHCP requests are relayed across VLAN boundaries using the firewall.

The relay mechanism is essential for enabling DHCP in a segmented network.

## Why DHCP Relay Is Required

DHCP clients use broadcast packets during address discovery.

In this architecture:
- User VLANs are isolated at Layer 3
- Broadcast traffic cannot cross VLAN boundaries
- The DHCP server is located in a different subnet

Without a relay, DHCP would fail by design.

## Relay Placement

The relay runs on the **firewall**, which:

- Has interfaces in all VLANs
- Acts as the default gateway
- Already enforces inter-VLAN policies

This makes the firewall the optimal location for DHCP relaying.

## Implementation

The relay service is implemented using:

- **ISC DHCP Relay (`isc-dhcp-relay`)**

The service is configured to:

- Listen on user VLAN bridges
- Forward requests to `192.168.40.10`
- Handle responses and forward them back to clients

## Packet Flow

The DHCP relay flow is as follows:

1. Client broadcasts `DHCPDISCOVER`
2. Firewall accepts the packet
3. Relay forwards it as unicast to the DHCP server
4. Server replies to the firewall
5. Firewall relays the response to the client

This behavior aligns with the documented traffic flows.

## Security Enforcement

Firewall rules ensure that:

- Only DHCP-related UDP traffic is allowed
- Relay traffic is limited to known interfaces
- No direct client-to-server communication occurs

!!! important
    The relay does not bypass firewall filtering. All DHCP traffic remains subject to policy enforcement.

# DNS Resolution Flow

This document describes the **DNS resolution paths** within the VNTD lab and how queries traverse the network.

Understanding these flows is essential for troubleshooting connectivity and resolution issues.

## Internal Name Resolution

When a client resolves an internal hostname:

1. The client sends a DNS query to the DNS server provided by DHCP
2. The query traverses the firewall
3. The DNS server resolves the name using its local zone
4. The response is returned to the client

No external communication occurs during this process.

## External Name Resolution

When a client resolves an external domain:

1. The client queries the internal DNS server
2. The DNS server determines the domain is not authoritative
3. The query is forwarded to an external DNS server
4. The external server responds
5. The response is relayed back to the client

Clients never communicate directly with external DNS servers.

## Firewall Enforcement

The firewall enforces DNS behavior by:

- Allowing DNS queries only to the internal DNS server
- Allowing forwarding traffic only from the DNS server
- Blocking direct client-to-Internet DNS traffic

This ensures all DNS traffic is centralized and observable.

## Relationship with Traffic Mirroring

DNS traffic traversing the firewall can be mirrored to the IDS using the same mechanisms described in the architecture.

This allows:

- Monitoring of DNS usage
- Detection of anomalous queries
- Analysis of potential malicious behavior

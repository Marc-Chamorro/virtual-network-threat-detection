# Network Design

The laboratory uses a topology where the `router_internet` represents the external Internet, the `router_enterprise` serves as the enterprise edge router connecting to the outside world, and the `firewall` acts as the gateway to all internal enterprise segments.

## IP Addressing Plan

The project uses a structured private IP plan to facilitate routing and firewall rule management:

| Zone | Subnet | Gateway |
| :--- | :--- | :--- |
| **Attacker** | 10.0.0.0/24 | 10.0.0.1 |
| **Benign** | 20.0.0.0/24 | 20.0.0.1 |
| **Network Core** | 192.168.0.0/30 | 192.168.0.1 |
| **DMZ (VLAN 10)** | 192.168.10.0/24 | 192.168.10.1 |
| **Monitoring (VLAN 20)** | 192.168.20.0/24 | 192.168.20.1 |
| **Admin (VLAN 30)** | 192.168.30.0/24 | 192.168.30.1 |
| **Services (VLAN 40)** | 192.168.40.0/24 | 192.168.40.1 |
| **Floor 1 (VLAN 50)** | 192.168.50.0/24 | 192.168.50.1 |
| **Floor 2 (VLAN 60)** | 192.168.60.0/24 | 192.168.60.1 |


## Communication Flows & Rules

The environment implements a <check if it has a name> model:

1.  **External to DMZ:** 
2.  **Internal to External:** 
3.  **Inter-VLAN:** 
4.  **Traffic Mirroring:**
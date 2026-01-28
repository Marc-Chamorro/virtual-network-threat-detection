# Topology Definitions

The project uses **Containerlab**'s YAML-based topology definition format (`.clab.yml`) to define the virtual network. This file acts as a *manager*, telling Docker which containers to start and how to link their network interfaces.

## File Structure

A typical topology file in this project follows this structure:

```yaml
name: virtual-env

topology:
  nodes:
    # Node definitions ...
  links:
    # Link definitions ...
```

### Nodes

The `nodes` section defines every device in the network. Each entry specifies:

!!! note
    Mandatory &rarr; **M**
    Optional &rarr; **O**

- `kind` [M]: The type of node (e.g., `linux` for standard containers, `arista_ceos` for switches). The kind must be supported by Containerlab.
- `image` [M]: The Docker image to use (e.g., `frr_vntd:latest`, `kali_vntd:latest`).
- `startup-config` [O]: Provide startup configuration that the node applies on boot.
- `binds` [O]: Files from the host's device that are mounted into the container to inject configurations.
- `exec` [O]: Commands to run immediately after the container starts (useful for IP assignment).
- `env` [O]: Environment variables (e.g., enabling `SSH_SERVER`).

!!! example
    `exec` and `binds` are commonly used together to inject configuration files into the container and then execute such scripts upon startup.

Additional sections definitions can be added to change the behavior and capabilities of devices to easily test the behavior under high-stress environments:

- `cpu` [O]: Define a maximum number of CPU cores to be assigned to a specific node. (e.g., `2`)
- `memory` [O]: Maximum amount of RAM available to a single node. (e.g., `4GB`)

### Example: Internet Router

```yaml
router_internet:
  kind: linux
  image: frr_vntd:latest
  binds:
    - ./config/router/daemons:/etc/frr/daemons
    - ./config/router/internet/frr.conf:/etc/frr/frr.conf
```

### Links
The `links` section defines the virtual cables connecting the nodes. Each link is defined by a pair of endpoints in the format `"node_name:interface_name"`.

### Example: Connecting Internet Router to Enterprise Router

```yaml
links:
  - endpoints: ["router_internet:eth3", "router_enterprise:eth1"]
```

## Runtime Artifacts

When a topology is deployed, Containerlab creates a directory named `clab-<topology_name>` (e.g., `clab-virtual-env`).

This directory contains:

- Generated certificates
- Node-specific runtime data
- Node configuration files

!!! warning
    The `clab-virtual-env` directory is **not permanent** and managed by Containerlab. Do **not** store permanent configurations here, as they may be wiped on redeployment. Always use the `config/` directory for persistent data or any other directory of your choice.

## Additional Resources

Here are some additional resources that may help create and manage custom topology definition files:

- Containerlab Supported Kinds: [Containerlab](https://containerlab.dev/manual/kinds/)
- Containerlab Topology Definition: [Containerlab](https://containerlab.dev/manual/topo-def-file/)
- Containerlab Nodes: [Containerlab](https://containerlab.dev/manual/nodes/)
- Containerlab Lab Directory and Configuration Artifacts: [Containerlab](https://containerlab.dev/manual/conf-artifacts/)

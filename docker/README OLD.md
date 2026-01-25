<a id="readme-top"></a>

# Docker Environment Images

This directory contains the **custom Docker images** required to run the project environment. Each image is either imported or built from a dedicated subdirectory and is intended to provide a **consistent** and **reproducible** environment for the labs.

The content allows:
1. **Building** custom iamges from Dockerfiles.
2. **Importing** vendor-provided images (e.g. Arista cEOS).
3. **Standardizing** the labs environment.

## Table of Contents

- [New Images](#new-images)
- [Directory Structure](#directory-structure)
- [Image Management](#image-management)
   - [Build](#build)
   - [Import](#import)
- [Managing Docker Images Manually](#managing-docker-images-manually)
   - [Manual Build](#manual-build)
   - [Manual Delete](#manual-delete)
- [Dockerfiles](#dockerfiles)
   - [Considerations](#considerations)
   - [Entrypoint](#entrypoint)
- [Best Practices](#best-practices)
- [Additional Resources](#additional-resources)



## New Images

New images can either be:
- **Imported**: Images such as Arista cEOS in `.xz` format can be imported by using the `docker/import` directory.
- **Built**: Custom images (e.g. Kali, Alpine) can be created using the existing `Dockerfile` files as templates.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Directory Structure
Each image pending to be built must follow this structure:
```
docker/build/
└─ <image-name>/
   ├─ Dockerfile
   ├─ entrypoint.sh     # optional
   └─ additional files  # optional
```

Images pending to be imported must be copied into:
```
docker/import/
```

### Example
```
docker/
├─ build/
│  └─ kali/
│     ├─ Dockerfile
│     └─ entrypoint.sh
├─ import/
│  └─ cEOS-lab-4.32.0F.tar.xz
└─ README.md
```

The name of the directory or name of the imported file (trimed at the first `-`) is used as the **base image name**, with **`_vntd`** appended when building/importing using the provided `run.sh` script.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Image Management

The provided `run.sh` script simplify managing the Docker images. If you want to automate building, deleting, or displaying images, the following are available:
- Build images
- Import images
- Delete images
- Display images

The build and import operations apppend **`_vntd`** to ease the managing, displaying and deletion process.

### Build
For each directory in the `docker/build/` directory, an image is built. The name used for building the image is the directory name. All files related to the image creation should be found within that directory to ease the build process and management.

### Import
Some external images are provided in compressed formats. These can be imported by placing them in the `docker/import/` directory. The import process builds images in the format:
- `.xz`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Managing Docker Images Manually

Refer to `run.sh` for simplified image management.

See [README](../README.md) for build, delete and view lab images.

### Manual Build
If an image is modified or newly added, it must be rebuilt. To manually build Docker images, follow these steps:

1. Navigate to the image directory:
```
cd docker/<new-image>
```

2. Build the image:
```
docker build -t <image_name> .
```

3. Verify the image:
```
docker image ls
```

### Manual Delete
To remove an image:
```
docker rmi <image-name>
```

To force deletion (e.g. if the image is in referenced by stopped containers):
```
docker rmi -f <image-name>
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Dockerfiles

These files define **custom images**. They are created to include additional packages, automate configurations, and eliminate manual repetition. By using these, we can ensure consistency across environments.

Such images include packages necessay to deploy and run the environment, such as:

#### Network Diagnostic Tools:
- `iproute2`, `net-tools`: Interface and route inspection.
- `iputils-ping`, `traceroute`: Connectivity testing.
- `curl`: Application-level connectivity testing.
- `tcpdump`: Packet capture and traffic analysis.
- `nmap`: Network discovery and port scanning.

#### Network connectivity and security:
- `frr`, `frr-pythontools`: Routing and network control.
- `iptables`: Firewall and packet filtering.
- `procps`: Enable IP forwarding and system tools.

### Considerations

#### Non-interactive Package Installation
```
ENV DEBIAN_FRONTEND=noninteractive
```
Prevents interactive prompts during package installation, ensuring reliable builds and automated environments.

#### Image Cleanup
The Dockerfile should remove cached packages after installation to keep disk usage low and improve manageability.

#### Behaviour
```
CMD ["sleep", "infinity"]
```
When **no custom entrypoint is defined**, this command should be placed at the end of the `Dockerfile`.  
It ensures the container remains running after startup instead of exiting immediately.

### Entrypoint
Some containers use a custom `entrypoint.sh` script that **runs every time the container starts**. This is useful for:
- Starting services
- Initializing environment variables
- Performing any initialitzation required

#### Behaviour
When an `entrypoint.sh` file is used, it typically contains a `sleep infinity` instruction.  
This keeps the container alive until it is manually stopped.

In this case, the `CMD ["sleep", "infinity"]` instruction in the `Dockerfile` is not required.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Best Practices
- Each image should be **independent** from one another
- Keep images **minimal** to reduce build time and disk usage
- Use **clear and consistent naming**, e.g. `*_vntd`
- **Rebuild** images after modifying the `Dockerfile` or `entrypoint.sh`

For more pre-built images, check the official [Docker hub](https://hub.docker.com/search) or other community sources.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Additional Resources

All images can be obtained freely. The following will require to register to download the image: Arista cEOS.

- Alpine extra: [Docker hub](https://hub.docker.com/r/wbitt/network-multitool)

- Arista cEOS: [Arista Software Downloads](https://www.arista.com/en/support/software-download)

- FRR Router: [FRRouting Releases](https://frrouting.org/release/10.5.0/)

- Debian slim: [Docker hub](https://hub.docker.com/layers/library/debian/12-slim/images)

- Kali Linux: [Docker hub](https://hub.docker.com/r/kalilinux/kali-rolling)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

IMPORTANT, LES CARPETES QUE COMENCEN AMB _ NO SERAN PROCESSADES PER ELS SCRIPTS DE BUILD
# Custom Docker Images

This directory contains the **custom Docker images** required to run the project environment.  Each image is built from a dedicated subdirectory and is intended to provide a consistent and reproducible environment for the labs.

New images can be added by creating a **new subdirectory** under this folder.

## Directory Structure
Each image must follow this structure:
```
docker
└─ <image-name>/
   ├─ Dockerfile
   ├─ entrypoint.sh # optional
   └─ additional files # optional
```

### Example
```
docker
├─ kali/
│  ├─ Dockerfile
│  └─ entrypoint.sh
└─ README.md
```

The name of the directory is used as the **base image name**, with **`_vntd`** appended when building using the provided `run.sh` script.

## Dockerfile

The provided `Dockerfile` defines a **custom image** (e.g. Linux-based) with commonly used networking and diagnostic tools. The provided Kali image provides the following:
- `iproute2`, `net-tools`
- `ping`, `traceroute`
- `curl`
- `tcpdump`
- `nmap`

### Consideration: Non-interactive Package Installation
```
ENV DEBIAN_FRONTEND=noninteractive
```
Prevents interactive prompts during package installation, ensuring reliable builds and automated environments.

### Image Cleanup
The Dockerfile should remove cached packages after installation to keep disk usage low and improve manageability.

### Behaviour
```
CMD ["sleep", "infinity"]
```
When **no custom entrypoint is defined**, this command should be placed at the end of the `Dockerfile`.  
It ensures the container remains running after startup instead of exiting immediately.

## Entrypoint

Some containers use a custom `entrypoint.sh` script that **runs every time the container starts**. This is useful for:
- Starting services
- Initializing environment variables
- Performing any initialitzation required

### Behaviour
When an `entrypoint.sh` file is used, it typically contains a `sleep infinity` instruction.  
This keeps the container alive until it is manually stopped.

In this case, the `CMD ["sleep", "infinity"]` instruction in the `Dockerfile` is not required.

# Image management

Refer to `run.sh` for simplified image management.
See [README](../README.md) for build, delete and view lab images.

## Build an Image
If an image is modified or newly added, it must be rebuilt.

### Manual build

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

## Delete an Image
To remove an image:
```
docker rmi <image-name>
```

Tom force deletion (e.g. if the image is in referenced by stopped containers):
```
docker rmi -f <image-name>
```

# Notes
- Each image should be **independent** from one another
- Keep images **minimal** to reduce build time and disk usage
- Use **clear and consistent naming**, e.g. `*_vntd`
- **Rebuild** images after modifying the `Dockerfile` or `entrypoint.sh`

More images at: https://hub.docker.com/r/praqma/network-multitool

## Reference
Additional Docker images can be found at: https://hub.docker.com/search.
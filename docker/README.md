<a id="readme-top"></a>

# Docker Environment Images

This directory contains the **custom Docker images** required to run the project environment. Each image is either imported or built from a dedicated subdirectory and is intended to provide a **consistent** and **reproducible** environment for the labs.

The content allows:
1. **Building** custom images from Dockerfiles.
2. **Importing** vendor-provided images (e.g., Arista cEOS).
3. **Standardizing** the labs environment.

## Table of Contents

- [Directory Structure](#directory-structure)
- [Workflow & Naming Format](#workflow--naming-format)
   - [Build Directory](#build-directory)
   - [Import Directory](#import-directory)
   - [Ignored Directories](#ignored-directories)
- [Image Management](#image-management)
   - [Automated Management](#automated-management)
   - [Manual Build & Debug](#manual-build--debug)
- [Dockerfile Guidelines](#dockerfile-guidelines)
- [External Resources](#external-resources)

## Directory Structure

The directory is organized to separate source files (buildable) from external elements (importable).

```
docker/
├── build/                 # Source code for custom images
│   ├── kali/              # Example: kali_vntd
│   │   ├── Dockerfile
│   │   └── entrypoint.sh
│   ├── alpine/            # Example: alpine_vntd
│   │   └── Dockerfile
│   └── _template/         # IGNORED: Starts with underscore
│       └── Dockerfile
├── import/                # Files for external images
│   └── cEOS-lab.tar.xz    # Example: ceos_vntd
└── README.md
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Workflow & Naming Format

The project scripts rely on a consistent naming format. When images are processed (built or imported) through the automation scripts (`run.sh`), the suffix **`_vntd`** is automatically appended to the resulting image tag to prevent conflicts with other local images.

### Build Directory

Location: `docker/build/`

Each directory represents a unique image. The name of the directory is used as the base name for the image.

- **Requirement:** Contains at least a `Dockerfile`.
- **Optional:** Can contain `entrypoint.sh` or other configuration files needed during the build.

### Import Directory

Location: `docker/import/`

Compressed image files are dropped here. The filename (trimmed at the first `-` character) is used as the base name.

- **Supported formats:** `.tar.xz` (only ensured for Arista cEOS).

### Ignored Directories

Any directory within `docker/build/` that starts with an underscore (`_`) will be **ignored** by the automation scripts.

- **Use case:** Useful for testing, keeping templates, or storing deprecated image sources without deleting them.
- **Example:** `docker/build/_mls` will not trigger a build process.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Image Management

### Automated Management

The primary way to interact with these images is through the project's main control script (`run.sh`), located in the project root. It handles:

- Building all valid directories in `docker/build/`.
- Importing all valid files in `docker/import/`.
- Applying the `_vntd` suffix automatically.

Please refer to the root [README](../README.md) for usage instructions on the automation scripts.

### Manual Build & Debug

For development purposes (e.g., testing a new `Dockerfile` before integrating it), you may need to build or remove images manually.

1. **Build an image manually:** Navigate to the specific image directory and build it. Consider the tag must be manually added if you want it to match the project convention.

```bash
cd docker/build/<image_directory>
docker build -t <image_name>_vntd .
```

2. **Verify the image:**
```bash
docker image ls --filter "reference=*_vntd"
```

3. **Remove an image:**
```bash
docker rmi <image_name>_vntd
```

*Use `-f` to force removal if the image is being used by a stopped container.*

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Dockerfile Guidelines

When creating a new image in `docker/build/`, follow these standards to ensure compatibility with the lab environment.

1. **Non-interactive Installation**
Always prevent interactive prompts during package installation to avoid build failures.
```Dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```

2. **Service Persistence**
Containers in this environment function as virtual network devices. They must not exit immediately after booting.
   - **With Entrypoint:** If you use an `entrypoint.sh` script, end it with `sleep infinity`.
   - **Without Entrypoint:** Add this CMD to the end of your `Dockerfile`:
```Dockerfile
CMD ["sleep", "infinity"]
```

3. **Cleanup**
To minimize image size, clean up cached package lists in the same layer as the installation:
```
RUN apt update && apt -y install \
    <packages> |
    && apt clean \
    && rm -rf /var/lib/apt/lists/*
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## External Resources

All images can be obtained freely. The following will require registration to download the image: Arista cEOS.

- Alpine extra: [Docker Hub](https://hub.docker.com/r/wbitt/network-multitool)

- Arista cEOS: [Arista Software Downloads](https://www.arista.com/en/support/software-download)

- FRR Router: [FRRouting Releases](https://frrouting.org/release/10.5.0/)

- Debian Slim: [Docker Hub](https://hub.docker.com/layers/library/debian/12-slim/images)

- Kali Linux: [Docker Hub](https://hub.docker.com/r/kalilinux/kali-rolling)

<p align="right">(<a href="#readme-top">back to top</a>)</p>
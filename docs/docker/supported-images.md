---
title: Supported External Images
icon: material/import
---

# Supported External Images

While most images are built from source Dockerfiles, the environment supports the integration of vendor-provided images.

## Import Directory

The automation scripts automatically search for compressed image archives in the following directory:

> `docker/import/`

!!! warning "Directory Requirement"
    If the `import` directory does not exist, it must be created manually before running the build scripts.

## Arista cEOS

The primary use case for the import functionality is integration of **Arista cEOS**. This allows users to work with an industry-standard CLI (Command Line Interface) indistinguishable from physical Arista switches.

!!! important
    Arista cEOS does not support assigning access lists to VLANs or ports. This feature is locked.

### Requirements
- **Format:** `.tar.xz`.
- **Naming:** The script names the image by trimming the filename at the first `-` and lower casing its characters.
- **Tagging:** The imported image will be tagged based on the previous recovered name and appended with `_vntd`.
    - *Example:* `cEOS-lab-4.32.0F.tar.xz` -> `ceos_vntd`.

### Licensing, Download & Import

!!! danger "Proprietary Software"
    Arista cEOS is **not open source** open source. Users must register for a valid account and accept the vendor's EULA to download the image from their support portal.

1.  Register at [Arista Software Downloads](https://www.arista.com/en/support/software-download).
2.  Navigate to **cEOS-lab** releases.
3.  Download the `.tar.xz` archive.
4.  Place the file in `docker/import/`.
5.  Run the project's build script.

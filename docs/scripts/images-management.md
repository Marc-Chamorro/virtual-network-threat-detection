# Image Management Scripts

Located in `scripts/images/`, these scripts automate the **Docker** build process. These are necessary to ensure all nodes in the topology run the correct customized software versions defined in the project.

## Interactive Menu (`images/menu.sh`)

**Role:** The controller for all Docker operations.
**Input:** Project root directory.
**Behavior:** Displays options to create, import, delete, or display images and calls the corresponding script based on user input.
**Command:**
```bash
./menu.sh /path/to/project/dir/virtual-network-threat-detection
```

## Create Script (`images/create.sh`)

**Role:** Builds custom Docker images from source.
**Input:** Project directory.
**Workflow:**
1. **Scanning:** Iterates through subdirectories in `docker/build/`.
2. **Filter:** Skips any directory starting with an underscore (`_`). This allows for "draft" folders to exist without breaking or building unnecessary images.
3. **Tagging:** Automatically tags the built image as `<directory_name>_vntd`.
    !!! example
        A folder named `kali` results in an image named `kali_vntd`.
4. **Build:** Executes `docker build -t <image_name> <directory>`.
**Command:**
```bash
./create.sh /path/to/project/dir/virtual-network-threat-detection
```

## Import Script (`images/import.sh`)

**Role:** Imports vendor-supplied images (e.g., Arista cEOS).
**Input:** Project directory.
**Workflow:** 
1. **Scanning:** Scans `docker/import/` for .tar.xz archives.
2. **Tagging:** Extracts the base name before the first hyphen (`-`) and converts it to lowercase, and appends `_vntd` at the end.
    !!! example
        `cEOS-lab-4.32.0F.tar.xz` → imported as `ceos_vntd`.
3. **Import:** Executes `docker import <file> <image_name>`.
**Command:**
```bash
./import.sh /path/to/project/dir/virtual-network-threat-detection
```

## Delete Script (`images/delete.sh`)

**Role:** Cleans up the created Docker images.
**Input:** None required.
**Workflow:**
1. **Filter:** Filters for all images with a name ending in `_vntd`.
2. **Delete:** Executes `docker rmi -f <image_name>` to force removal.
3. **Safety:** Only affects images with the project suffix, leaving other system images intact.
**Command:**
```bash
./delete.sh
```

## Display Script (`images/display.sh`)

**Role:** Lists project-specific images.
**Input:** None required.
**Behavior:** Filters docker images using `*_vntd` as reference and displays image details.
**Command:**
```bash
./display.sh
```
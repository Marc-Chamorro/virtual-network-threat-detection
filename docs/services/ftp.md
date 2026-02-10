# FTP Service

This document describes the **FTP service implementation** used in the laboratory.

The FTP service is provided by **vsftpd** and is enabled conditionally at container startup.

---

## Service Activation

The FTP service is enabled only if the following environment variable is set:

```yml
env:
    FTP_SERVER: 1
```

If the variable is not set (or set to any other value), the SSH service is not started.

Additionally, the containerlab element requires the following attribute:

```yml
runtime: docker
```

If this attribute is not provided, there is a risk that the FTP service may break not only the container using it, but also other containers.

It is therefore strongly recommended to include it.

!!! note
    This allows the same server image to be reused with or without FTP enabled.

---

## User Creation

FTP users are created automatically at startup based on a configuration file.

### Source file

Users are defined in:

```bash
/labs/config/server/ftp/vsftpd.chroot_list
```

Example content:
```text
user5_1
user5_2
user6_1
user6_2
userAdmin
```

**Rules:**
- Empty lines are ignored
- Lines starting with `#` are ignored
- Each valid line represents one FTP user

---

### Default Credentials

All FTP users share the same default password.

| Parameter | Value  |
|-----------|--------|
| Password  | `pswd` |

!!! warning
    These credentials are intentionally weak.
    They exist solely for lab and testing purposes.

---

## Home Directories and Isolation

For each FTP user:
- A dedicated home directory is created:
    ```text
    /ftp/<username>
    ```
- The user is chrooted to this directory
- Users cannot access other users’ files
- Shell access is disabled (`/sbin/nologin`)

Permissions:
- User has full control over their own directory
- No access outside their chroot

!!! info
    This setup mirrors a simple multi-user internal FTP service.

---

## FTP Behaviour

Once configured, the FTP service is started using the system service manager:

```bash
service vsftpd start
```

FTP traffic:
- Uses TCP port 21
- Traverses firewall and routing policies

!!! note
    Packages can be observed and analyzed to detect unencrypted traffic.

---

## How to use

The Alpine client images include lftp, which is used to interact with the FTP service.

---

**Connecting:**
```bash
lftp user5_1@internal.enterprise.local # The IP address can also be used
```

When prompted, enter the default password:

```bash
pswd
```

Once connected, the user is placed directly in their home directory.

The available hostnames are defined in the DNS configuration:
- [DNS Names Assignment](../network-services/dns/server.md)

!!! info
    From the provided topology, the FTP service is available only on the `internal_server` using the `server_vntd` image.
    By default, all servers have a DNS-resolvable hostname.

---

**Uploading Files:**

Create a file locally:

```bash
echo "hello ftp" > test.txt
```

Upload it to the server:

```bash
put test.txt
```

---

**Downloading Files:**


List files on the server:

```bash
ls
```

Download a file:

```bash
get test.txt
```

---

**Creating Directories:**

```bash
mkdir docs
```

---

**Deleting Files or Directories:**

Delete a file:

```bash
rm test.txt
```

Delete a directory:

```bash
rmdir docs
```

---

**Modifying Files:**

Files can be overwritten by re-uploading them:

```bash
put test.txt
```

---

**Exiting the Session:**

```bash
exit
```
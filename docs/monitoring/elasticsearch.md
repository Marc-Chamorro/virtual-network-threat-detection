---
title: Elasticsearch
icon: material/database-search
---

# Elasticsearch

Elasticsearch acts as the **central log storage and indexing engine** for the monitoring infrastructure.

It receives structured events from **Filebeat**, stores them internally as documents and allows efficient querying and visualization through **Kibana**.

Therefore, *Elasticsearch* is responsible for:
- Central service for storing data.
- Monitoring stack core service for communication between all services.
- Indexing and analyzing data.

---

## Architecture

Elasticsearch is responsible for **data storage and indexing** within the monitoring pipeline.

```mermaid
flowchart LR

    FILEBEAT[Filebeat]
    ELASTIC[Elasticsearch]
    KIBANA[Kibana]

    FILEBEAT --> ELASTIC
    ELASTIC --> KIBANA
```

Elasticsearch acts as the core service for all Elastic components. It receives data and provides it for further analysis and processing.

---

## Service Activation

Elasticsearch is started only when the following variable is set:

```yaml
env:
    ELASTIC_STACK: 1
```

If the variable is not set, none of the Elastic components (Elasticsearch, Filebeat, Kibana) start.

This allows disabling the full monitoring stack when running the laboratory on lower resource systems.

---

## Startup Behaviour

The monitoring container `entrypoint` performs the followign operations:

1. Adjust kernel parameters recommended to run Elasticsearch.
    ```bash
    sysctl -w vm.max_map_count=262144
    ```
    !!! note "Memory Requirement"
        Although not necessary to set such parameter, Elastic official documentation suggests may help the service run smoother.
2. Start the Elasticsearch service.
3. Wait for the API service to be up and running.
4. Configures security users and roles.

Example startup command:
```bash
    su -s /bin/bash elasticsearch -c "/usr/share/elasticsearch/bin/elasticsearch" &
```

The service must be executed using the **elasticsearch** user. This profile is automatically created by the elastic installer and needs no additional manual configuration to use. Hence, the use of `su` (switch user) and the `-s` (use bash as the shell) and `-c` (which operation to execute) parameters.

---

## File Structure and Configuration

Elasticsearch configuration is provided through binds.

Elasticsearch primary configuration file:

```bash
/etc/elasticsearch/elasticsearch.yml
```

This file defines:
- Service behaviour.
- Security settings.
- Node roles.
- Network parameters.

Bind example:

```yaml
binds:
  - ./config/logwatch/elasticsearch/elasticsearch.yml:/etc/elasticsearch/elasticsearch.yml
  - ./config/logwatch/elasticsearch/heap.options:/etc/elasticsearch/jvm.options.d/heap.options
```

*See heap.options file in the next point*

This allows modifying the Elasticsearch service behavior without rebuilding the container image.

### Heap Options

Elasticsearch consumes a significant amount of RAM. By default, it allocates aroung **50%** of the total memory to Elasticsearch.

Although it's often recommended to allocate **16GB** to the service, many users cannot afford to dedicate so many resources.

Therefore, the amount of RAM consumed by the service can be limited in the `heap.options` file.

```bash
/etc/elasticsearch/jvm.options.d/heap.options
```

This file defines the amount of RAM allocated to the Elasticsearch JVM. In this laboratory environment, the RAM consumption has been limited to **2GB**, although it can be further reduced to **1GB** given the scale of the environment.

```options
-Xms2g
-Xmx2g
```

- `Xms` - initial heap size.
- `Xmx` - maximum heap size.

For best performance, both values should be set to the **same value**.

---

## Data Storage

Elasticsearch stores its data inside the directory:

```bash
/var/lib/elasticsearch
```

!!! note "No persistence"
    Given it's a Containerlab environment, data persistence is not possible since the environment is designed to be cleaned at every execution.

---

## Security Configuration

During container initialization the entrypoint automatically configures several elements.

### Elastic Superuser

Default system user:
> elastic

The password is automatically generated during installation and displayed on the terminal.
Since obtaining this value may be difficult in an automated environment or may need to be updated, the following tool is used:

```bash
    RESET_OUTPUT=$(/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -b)
```

Then, from the given response, it's extracted and stored during the entrypoint execution for configuring the environment and creating additional users.

The password is random and cannot be specifically set.

!!! note "Filebeat"
    The password is later used by Filebeat to set up its service.

### Kibana System User

User:
> kibana_system : pswd_vntd

This user allows Kibana to communicate with Elasticsearch. This user is already provided by the Elasticsearch service and only needs to have a new password.

### Filebeat Internal User

A dedicated user is created for Filebeat:
> filebeat_internal : pswd_vntd

With the aassociated role created as well:
> filebeat_writer

!!! note "New User"
    The justification for this decision can be found at [Filebeat](./filebeat.md).

Permissions included:

| Permissions    | Type    | Purpose                   |
|----------------|---------|---------------------------|
| monitor        | cluster | Read cluster status       |
| read_ilm       | cluster | Read lifecycle policies   |
| read_pipeline  | cluster | Read ingest pipelines     |
| manage_ilm     | cluster | Manage lifecycle policies |
| manage         | cluster | Cluster admin operations  |
| all            | cluster | Full cluster admin        |
| auto_configure | index   | Auto-create indices       |
| create_doc     | index   | Insert new documents      |
| write          | index   | Full document writes      |
| create         | index   | Index new documents       |
| create_index   | index   | Create indices            |
| manage         | index   | Full index admin          |

This ensures Filebeat can send logs and properly communicate with Elasticsearch.

### Administrator User

A new administrative user is created for the Kibana web login.
> admin : 12345aA

This user has the **superuser role**.

!!! warning "Weak credentials"
    These credentials are intentionally weak and should only be used in isolated and controlled environments.

---

## API Access & Verification

The Elasticsearch service publishes a REST API.

Default port:
> 9200

Default endpoint:
>http://localhost:9200

Example terminal request:
```bash
curl http://localhost:9200
```

This previous request can be also be used to check whether the environment is up and working or not.

The site can also be accessed from a web explorer.

!!! important "Localhost -> IP Address"
    To connect to the web site for testing the environment and it's accessibility, use the Containerlab generated IP management address.

You can verify the health of the service directly from the terminal from the same machine:

```bash
curl -X GET "http://localhost:9200/_cluster/health?pretty"
```

---

## Additional Resources

For additional documentation, check the official documentation:

- [Docs - Elasticsearch](https://www.elastic.co/docs/reference/elasticsearch)

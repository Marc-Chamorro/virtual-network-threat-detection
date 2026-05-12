---
title: Commands Reference
icon: material/console
---

# Commands Reference

Useful commands for managing, troubleshooting and interacting with the VNTD laboratory. All commands run from the **host machine** unless stated otherwise.

---

## Installation & Setup

```bash
# System update and essential tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ssh python3 python3-pip python3-venv

# Git LFS (model and dataset files)
sudo apt install git-lfs
git lfs install
git lfs pull

# Docker (alternative if Containerlab script fails)
curl -sSL https://get.docker.com/ | sudo sh
sudo usermod -aG docker $USER

# Containerlab
curl -sL https://containerlab.dev/setup | sudo -E bash -s "all"
sudo usermod -aG clab_admins $USER

# Verify installs
clab version
docker run hello-world
```

---

## Containerlab

```bash
# Deploy a topology
sudo clab deploy -t labs/topology.clab.yml

# Destroy a topology
sudo clab destroy -t labs/topology.clab.yml

# Destroy and remove all volumes and configs
sudo clab destroy -t labs/topology.clab.yml --cleanup

# Inspect all running topologies
sudo clab inspect --all

# List only Containerlab-managed containers
docker ps --filter "label=clab-node-name"
```

---

## Docker

### Containers

```bash
# List running containers
docker ps

# List all containers including stopped ones
docker ps -a

# Open a shell inside a container
docker exec -it clab-virtual-env-pc-vlan50-1 bash

# Open a shell as root
docker exec -it -u root clab-virtual-env-logwatch bash

# View startup logs of a container
docker logs clab-virtual-env-internal-server

# Follow logs in real time
docker logs -f clab-virtual-env-logwatch

# Filter logs by keyword
docker logs -f clab-virtual-env-logwatch 2>&1 | grep -Ei 'elastic|filebeat|kibana'

# Real-time CPU and memory usage of all containers
docker stats
```

### Images

```bash
# List all local images
docker images

# Show disk usage per image
docker system df -v

# Remove a specific image
docker rmi <image_name>

# Remove all dangling (untagged) images
docker image prune

# Remove ALL unused images, containers, networks and build cache
docker system prune -a
```

### File permissions

```bash
# Fix filebeat.yml permissions
sudo chmod 644 labs/config/logwatch/filebeat/filebeat.yml ```
---

## Suricata

```bash
# Test configuration file for syntax errors
suricata -T -c /etc/suricata/suricata.yaml

# Follow eve.json as events arrive (inside the container)
tail -f /var/log/suricata/eve.json

# Same from the host
docker exec clab-virtual-env-logwatch tail -f /var/log/suricata/eve.json

# Follow Suricata's own log (rule loading, errors)
tail -f /var/log/suricata/suricata.log

# View last 100 events
docker exec clab-virtual-env-logwatch tail -n 100 /var/log/suricata/eve.json
```

---

## Elasticsearch & Kibana

```bash
# Cluster health
curl http://192.168.20.11:9200/_cluster/health?pretty

# List all indices
curl -X GET "http://192.168.20.11:9200/_cat/indices?v"

# List shards
curl -X GET "http://192.168.20.11:9200/_cat/shards?v"

# List data streams
curl http://192.168.20.11:9200/_data_stream?pretty

# Filebeat internal stats (from inside logwatch)
curl -s http://localhost:5066/stats

# Generate a new Kibana enrollment token (inside logwatch)
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

# Generate an encryption key
openssl rand -hex 32
```

---

## Traffic Inspection

```bash
# All traffic on an interface
tcpdump -i eth1 -nn

# ICMP only
tcpdump -i eth1 icmp -nn

# DHCP traffic
tcpdump -i <port> -f 'port 67 or port 68'

# Count connections to port 80 (useful during a SYN flood)
netstat -ant | grep :80 | wc -l

# Socket summary by state
ss -s
```

---

## Services (inside a container)

```bash
# List all services and their state
service --status-all

# All running processes
ps aux
```

---

## Client / User Commands

### Connectivity

```bash
# Test reachability
ping enterprise.local
ping 192.168.10.10

# Download or test a web response
wget http://enterprise.local
curl http://enterprise.local
curl http://enterprise.com
curl http://internet.com

# Continuously poll a web server (useful during a DoS attack)
while true; do curl -s enterprise.com; sleep 5; done
```

### DNS

```bash
# Check which DNS server the node is using
cat /etc/resolv.conf

# Basic name resolution
nslookup enterprise.local
nslookup 192.168.10.10
nslookup internet.com

# Detailed query output
dig www.enterprise.local
```

| Zone | Known IP addresses |
|---|---|
| Internal DNS | `192.168.10.10`, `192.168.40.10` |
| External DNS | `172.16.100.100`, `172.16.30.2` |

??? example "nslookup output examples"
    ```
    pc_enterprise:/# nslookup enterprise.local
    Server:     192.168.10.10
    Address:    192.168.10.10#53
    Name:       enterprise.local
    Address:    192.168.10.10
    ```
    ```
    pc_enterprise:/# nslookup internet.com
    Server:     192.168.10.10
    Address:    192.168.10.10#53
    Name:       internet.com
    Address:    172.16.100.100
    ```

### DHCP

```bash
# Force a new IP address request from the DHCP server
dhcpcd -4 -d eth1
```

### Mail (Mutt)

```bash
# Launch the mail client
mutt
```

| Action | Key |
|---|---|
| Start writing | `i` |
| Save and exit editor | `:wq` |

!!! note
    Mutt does not refresh the inbox automatically. Exit and reopen to see new emails.

---

## ML - Python Environment

```bash
# Create the virtual environment
python3 -m venv venv

# Activate
source venv/bin/activate

# Install dependencies
pip install -r ml/requirements.txt
pip install jupyter

# Deactivate
deactivate
```

---

## ML - Jupyter Notebook

```bash
# Launch from the project root (venv must be active)
jupyter notebook ml/notebooks/VNTD_ML.ipynb

# Headless VM - no browser (then forward port 8888 via SSH)
jupyter notebook --no-browser ml/notebooks/VNTD_ML.ipynb

# SSH tunnel from local machine
ssh -L 8888:localhost:8888 user@<vm-ip>
```

---

## ML - Real-Time Detector

```bash
# Via the main menu (recommended)
sudo ./run.sh

# Directly via script
sudo bash scripts/ml/ml_detect.sh "$(pwd)"

# Manually (venv must be active)
cd ml/realtime
python3 detect.py \
    --container      clab-virtual-env-logwatch \
    --models         ../models \
    --batch          5000 \
    --flush-interval 30 \
    --eve-log        /var/log/suricata/eve.json \
    --threshold      -0.5614
```

# Deployment

This section explains how to deploy and run the lab environment.

---

## 🚀 Deployment Strategy

The environment is deployed using:

- Containerlab
- Docker
- Predefined topology files

---

## 📋 Prerequisites

Before starting, make sure you have:

- Docker installed
- Containerlab installed
- Sufficient system resources

---

## ▶️ Basic Workflow

```bash
git clone <repository>
cd virtual-network-threat-detection
containerlab deploy
```

---

## 🧹 Cleanup

To destroy the lab:

```bash
containerlab destroy
```

!!! important
    Always clean up resources after testing to avoid conflicts.
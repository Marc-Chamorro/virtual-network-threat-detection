---
title: ML Environment Setup
icon: material/language-python
---

# ML Environment Setup

This page explains how to set up the Python environment for the **ML module**:

- **Automation Script (`ml_detect.sh`)** -> for real-time anomaly detection (no Jupyter required)
- **Jupyter Notebook** -> for training / experimentation

!!! info "Scope"
    This setup only applies to `ml/`. The main lab (Docker + Containerlab) does not require Python on the host.

---

## Prerequisites

| Requirement    | Version       | Notes                                |
|----------------|---------------|--------------------------------------|
| **Python**     | 3.10 or later | Must be available as `python3`       |
| **pip**        | Latest        | Comes with Python                    |
| **Virtualenv** | Included      | Via `python3-venv`                   |
| **Jupyter**    | Latest        | Not required for real-time detection |

---

## 1. Verify Python Installation

```bash
python3 --version
```

If Python is not installed, install it on Ubuntu/Debian:

```bash
sudo apt update && sudo apt install python3 python3-pip python3-venv -y
```

---

## 2. Automation Script (Real-Time Detection)

The easiest way to launch the real-time detector is through the `ml_detect.sh` script (or the main `run.sh` menu). It handles the full Python environment automatically; no manual setup required.

```bash
sudo ./run.sh
```

The script performs all of the following steps automatically:

1. Checks that `python3` is available on the host.
2. Creates `venv/` at the project root if it does not exist.
3. Upgrades `pip` inside the virtual environment.
4. Installs all packages from `ml/requirements.txt` if not present.
5. Verifies that the model files (`scaler.pkl`, `isolation_forest.pkl`, `model_threshold.txt`) exist in `ml/models/`.
6. Verifies that the `logwatch` container is running.
7. Launches the `detect.py` terminal interface.

!!! note "Manual setup"
    If you prefer to prepare the environment manually before running the script, follow the steps in the [Jupyter section](#3-jupyter-notebook-training) below. The script will detect the existing `venv/` and skip creation.

### Dependencies

The packages installed by the script come from `ml/requirements.txt`:

| Package        | Purpose                                          |
|----------------|--------------------------------------------------|
| `scikit-learn` | Isolation Forest, StandardScaler, metrics        |
| `pandas`       | DataFrame loading and manipulation               |
| `numpy`        | Numeric operations                               |
| `joblib`       | Saving and loading sklearn model objects         |

---

## 3. Jupyter Notebook (Training)

If you want to open the notebook and retrain the model, start the Jupyter server with the virtual environment active.

### Create Virtual Environment

A virtual environment keeps the ML dependencies isolated from the system installation. Create it inside the project root:

```bash
python3 -m venv venv
```

This creates a `venv/` directory at the root of the project containing an isolated Python interpreter and its own `pip`.

!!! note "Location"
    The `ml_detect.sh` script expects the virtual environment at `<project_root>/venv/`. Placing it elsewhere requires updating `VENV_DIR` in `scripts/ml/ml_detect.sh`. If not, the script will create a new one.

### Activate the Environment

```bash
source venv/bin/activate
```

Once active, the terminal prompt will show `(venv)`. To deactivate later:

```bash
deactivate
```

### Install Dependencies

```bash
pip install -r ml/requirements.txt
```

### Install Jupyter

```bash
pip install jupyter
```

### Launch Jupyter

```bash
jupyter notebook ml/notebooks/VNTD_ML.ipynb
```

The browser will open automatically at `http://localhost:8888`. If it does not, copy the URL printed in the terminal.

!!! tip "Run from the project root"
    Starting Jupyter from the project root ensures that relative paths inside the notebook (`../data/attacks.json`, `../models/scaler.pkl`, etc.) are used correctly.

To run the full training pipeline, use **Restart the kernel and run all cells**.

---

## Troubleshooting

**`python3: command not found`**: Python is not installed or not in `PATH`. Install it with `sudo apt install python3`.

**`pip install` fails with externally-managed-environment error**: Always install inside the virtual environment. Make sure `source venv/bin/activate` was run first.

**Broken virtual environment after OS upgrade**: Delete `venv/` and recreate it:
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r ml/requirements.txt
```

**Jupyter notebook does not find the data files**: Start the Jupyter server from the **project root** directory, not from inside `ml/notebooks/`.

**Model files not found by the detector**: Ensure `git lfs pull` has been run after cloning. The `.pkl` files are stored in Git LFS and will appear as empty pointer files if LFS was not pulled.
```bash
git lfs install
git lfs pull
```
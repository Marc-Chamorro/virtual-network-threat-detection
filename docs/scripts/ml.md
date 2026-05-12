---
title: ML Scripts
icon: material/console
---

# ML Scripts

The `scripts/ml/` directory contains the shell scripts that automate the setup and launch of the **real-time anomaly detection** system.

```
scripts/ml/
├── menu.sh        # Interactive submenu for ML operations
└── ml_detect.sh   # Launches the real-time Isolation Forest detector
```

These scripts are invoked from the main `run.sh` menu. They can also be executed directly.

---

## menu.sh

**Role:** Provides the interactive submenu for ML-related operations when accessed through the main `run.sh` menu.

**Input:** The project root directory (`PRJ_DIR`) received from the parent menu.

**Behaviour:**

- Option `1` calls `ml_detect.sh` with the project root as argument.
- Option `2` returns to the parent menu.

**Usage (from main menu):**

```bash
sudo ./run.sh
# > ML Anomaly Detection
```

**Direct usage:**

```bash
./menu.sh /path/to/project/dir/virtual-network-threat-detection
```

---

## ml_detect.sh

**Role:** Full startup and launch script for the real-time anomaly detector.

**Location:**
```
scripts/ml/ml_detect.sh
```

**Usage:**

```bash
./ml_detect.sh /path/to/project/dir/virtual-network-threat-detection
```

### What the Script Does

The script performs all necessary checks and setup before launching the Python detector. It takes the **project root path** as its only argument and proceeds through the following stages:

**1. Path resolution**
All paths are derived from the provided project root: the Python detection script, the models directory, the threshold file, and the virtual environment.

**2. Python check**
```bash
command -v python3
```
If `python3` is not found in `PATH`, the script exits with a clear error. Python must be installed on the host before running this script.

**3. Virtual environment setup**
```
venv/                  # Created at the project root
venv/bin/python        # Python interpreter used for detection
venv/bin/pip           # Pip used to install dependencies
```
If `venv/` does not exist, it is created with `python3 -m venv`. If the venv is broken, it is deleted and recreated.

**4. Dependency installation**
Dependencies are installed from `ml/requirements.txt` if the key packages are not yet importable. If `requirements.txt` is missing, the core packages (`scikit-learn`, `pandas`, `numpy`, `joblib`) are installed directly.

**5. Model file verification**
The script confirms that the following files exist before proceeding:

| File                              |
|-----------------------------------|
| `ml/models/scaler.pkl`            | 
| `ml/models/isolation_forest.pkl`  |
| `ml/models/model_threshold.txt`   |

If any file is missing, the script exits with an error. The pre-trained model files are included in the repository (via Git LFS). If they are absent, run `git lfs pull`.

**6. Container verification**
The script checks that the `logwatch` container is running using `docker ps`. The expected container name is:

```
clab-virtual-env-logwatch
```

If the container is not running, the script lists all active containers to help identify any naming mismatch and then exits.

**7. Launch**
Once all checks pass, the Python detector is started:

```bash
python detect.py \
    --container  clab-virtual-env-logwatch \
    --models     ml/models/ \
    --flush-interval 30 \
    --batch      5000 \
    --eve-log    /var/log/suricata/eve.json \
    --threshold  <value from model_threshold.txt>
```

### Configuration Constants

The following values are defined at the top of the script and can be modified if needed:

| Variable             | Default                            | Description                                            |
|----------------------|------------------------------------|--------------------------------------------------------|
| `LAB_NAME`           | `virtual-env`                      | Containerlab lab name (must match `topology.clab.yml`) |
| `LOGWATCH_CONTAINER` | `clab-virtual-env-logwatch`        | Full container name of the logwatch node               |
| `EVE_LOG`            | `/var/log/suricata/eve.json`       | Path to the Suricata event log inside the container    |
| `BATCH`              | `5000`                             | Number of events to buffer before scoring              |
| `FLUSH_INTERVAL`     | `30`                               | Maximum seconds between scoring batches                |

---

## Prerequisites

Before running `ml_detect.sh`:

1. **Python 3.10+** installed on the host.
2. A **topology is deployed** and the `logwatch` container is running.
3. The **model files** are present in `ml/models/` (included via Git LFS).

For full setup instructions, see the [ML Environment Setup](../ml/setup.md) page.

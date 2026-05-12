---
title: Models
icon: material/folder-cog-outline
---

# Models

The `ml/models/` directory contains the **pre-trained objects** produced by the last run of the Jupyter notebook, plus the evaluation charts generated during that run.

```
ml/models/
├── isolation_forest.pkl           # Trained Isolation Forest model
├── scaler.pkl                     # StandardScaler fitted on benign data
├── model_threshold.txt            # Anomaly score threshold (-0.5614)
├── confussion_matrix.png          # Confusion matrix of the evaluation run
├── feature_distributions.png      # Feature distributions: benign vs attack
├── roc_curve.png                  # ROC curve with AUC score
├── score_distribution.png         # Anomaly score histograms for both classes
└── time_window_distributions.png  # Time-window feature distributions
```

!!! note "Git LFS"
    `isolation_forest.pkl` and `scaler.pkl` are tracked via **Git Large File Storage (LFS)** due to their size. Run `git lfs pull` after cloning to download them.

---

## isolation_forest.pkl

The **Isolation Forest** model is trained exclusively on benign Suricata events.

| Parameter       | Value   | Purpose                                              |
|-----------------|---------|------------------------------------------------------|
| `n_estimators`  | 12,000  | Number of random decision trees                      |
| `max_samples`   | `auto`  | Each tree samples a random subset of the data        |
| `max_features`  | 0.6     | Each tree uses 60% of the features for diversity     |
| `contamination` | 0.12    | ~12% of training data assumed to be slightly unusual |
| `random_state`  | 42      | Ensures reproducible results across runs             |
| `n_jobs`        | -1      | Uses all available CPU cores during training         |

The model uses **26 features** derived from the Suricata events (see [Notebook – Step 6](./notebook.md#step-6---select-features)). It assigns an **anomaly score** to each event: the more negative the score, the more suspicious the event. Events below the threshold are flagged as anomalies.

!!! info "How Isolation Forest works"
    The algorithm builds many random decision trees. Normal events look like many other events, so they are hard to isolate and require many decisions to separate. Anomalous events look unusual, so they are separated in very few splits. The path length to isolate an event is directly converted into the anomaly score.

---

## scaler.pkl

A **StandardScaler** is fitted on the benign training data.

Before the model can score an event, all numeric features must be brought to a common scale. Raw features have very different magnitudes: `flow_bytes_toserver` can reach thousands, while `tcp_syn` is simply 0 or 1. Without scaling, the model would disproportionately weight large-magnitude features.

`StandardScaler` transforms every feature so that it has **mean = 0** and **standard deviation = 1**, using the statistics learned from the benign training data.

!!! warning "Consistent scaling"
    The same scaler must be used for both training and inference. The real-time detection pipeline (`pipeline.py`) loads this scaler and applies `transform()` (never `fit_transform()`) on incoming events to ensure identical preprocessing.

---

## model_threshold.txt

A plain text file containing a single value: the **anomaly score threshold** computed at training time.

```
-0.5614
```

The threshold is recovered from `model.offset_`, the internal Isolation Forest decision boundary based on the configured `contamination` parameter. Events with a score **below** this value are classified as anomalies.

The real-time detector reads this file at startup. If the file is absent, the detector falls back to `model.offset_` read directly from the loaded model object.

---

## Evaluation Charts

The following images are saved during the execution of the notebook and serve as a visual register of the model's performance on the evaluation dataset.

### score_distribution.png

Show a histogram of the anomaly score for benign events (blue) and attack events (red), with the decision threshold as a dashed vertical line.

A well-trained model should show the attack distribution sitting to the **left** (more negative) of the benign distribution, with a gap between the two peaks.

### confussion_matrix.png

A confusion matrix comparing predicted labels (normal / anomaly) against the 'real' labels from the evaluation dataset.

| Term                | Meaning                                      |
|---------------------|----------------------------------------------|
| True Positive (TP)  | Attack event correctly flagged as anomaly    |
| True Negative (TN)  | Benign event correctly identified as normal  |
| False Positive (FP) | Benign event incorrectly flagged as anomaly  |
| False Negative (FN) | Attack event missed (not flagged)            |

### roc_curve.png

Plots the relationship between true positives and false positives across different thresholds. The **Area Under the Curve (AUC)** summarises the separability of the two classes; a value of 1.0 means perfect separation.

### feature_distributions.png

Displays the features distributions for benign vs attack data. This is useful for visually confirming that a given feature has discriminative values. Features where the two distributions overlap heavily, contribute less to classes separation.

### time_window_distributions.png

Same as above, but focused specifically on the **time-window features** (`flows_to_dest_port_wndw`, `unique_srcs_to_dest_wndw`, `flows_from_src_wndw`, `unique_dest_ports_from_src_wndw`). These are among the strongest signals for volume-based attacks like DoS and port scans.

---

## Using the Pre-Trained Model

The included model can be used directly without retraining. The `ml_detect.sh` script (or the `run.sh` menu) loads these files automatically and launches the real-time detector.

If you want to retrain the model with new data, open the notebook and re-run all cells. The new objects will overwrite the existing files in `ml/models/`.

For full retraining instructions, see the [Notebook](./notebook.md) documentation.

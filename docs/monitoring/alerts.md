---
title: Alerts & Detection Rules (≈ SIEM)
icon: material/alert-outline
---

# Alerts & Detection Rules (≈ SIEM)

This section focuses on how **Suricata detections are converted into Kibana alerts**, and how detection rules are defined and used.

This approach is chosen because it is the **simplest and fastest way** to integrate Suricata with Elastic.  
Manually creating rules is time-consuming, and enabling all default Elastic rules is resource-intensive.

However, prebuilt Elastic rules are still available for experimentation and learning.

Rule configuration is applied in the node `entrypoint`.

---

## Detection Layers

Alerting is split into two independent layers:

| Layer    | Role                                    |
|----------|-----------------------------------------|
| Suricata | Generates detection events (`eve.json`) |
| Elastic  | Converts events into alerts             |

!!! note "Suricata -> Kibana"
    Suricata does **not** create Kibana alerts directly.

---

## Suricata Alert Definition

Only events containing the following field are considered security detections:

```text
suricata.eve.event_type: alert
```

All other event types (flows, DNS, HTTP, etc.) are ignored by detection rules.

---

## Generic Detection Rule

The main rule used in this environment searches for all events matching:

```json
event.module:suricata AND suricata.eve.event_type:alert
```

**Behavior:**
- Matches all Suricata alerts
- Works across:
    - filebeat-*
    - .ds-filebeat-*
- Runs periodically (e.g. every 1 minute)

!!! tip "Bridge Rule"
    This acts as a bridge: it converts every IDS detection into a SIEM alert.

---

## Alert Naming

By default, Kibana rules use static names.
To preserve Suricata context, alerts should reference:

```
suricata.eve.alert.signature
```

This ensures alerts reflect the original rule, for example:
- >ET SCAN Suspicious inbound to MySQL port 3306
- >ET SCAN Potential VNC Scan

## Why Alerts May Not Appear

!!! warning
    Data can be processed correctly and still not generate alerts.

Common causes:
- No detection rule enabled.
- Query does not match `event_type: alert`.
- Incorrect index pattern.
- Not waited enough time for the data to be processed.
- Time window too small.
- Traffic is not considered malicious by Suricata rules.

---

## Additional Rules

Additional rules can be defined directly in the `entrypoint` to detect more specific behaviors.

Examples:

- Port scan detection
    ```
    suricata.eve.alert.signature:*Scan*
    ```
- DoS / flood detection
    ```
    suricata.eve.alert.signature:*flood* OR suricata.eve.alert.signature:*DoS*
    ```
- Service-specific alerts
    ```
    suricata.eve.alert.signature:*SSH* OR suricata.eve.alert.signature:*FTP*
    ```

!!! tip "Use Case"
    The generic rule provides full visibility, while additional rules allow filtering and prioritization.

# Suricata

Suricata is used as the **primary intrusion detection system** in this lab.

---

## 🛡️ What is Suricata?

Suricata is a high-performance IDS/IPS capable of:

- Signature-based detection
- Protocol analysis
- File extraction

---

## ⚙️ How it is used in this lab

Suricata runs as a container connected to a monitoring interface.

Key characteristics:

- Passive IDS mode
- Custom rule sets
- JSON log output

---

## 📂 Outputs

Suricata generates:

- Alerts
- Flow logs
- Statistics

```text
alert.signature
alert.severity
flow.bytes
```
!!! tip
    Start with a small rule set to avoid alert noise.
    
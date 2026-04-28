# Task 3 -- Container Monitoring

## Objective

Monitor container resource usage by logging CPU and memory with timestamps automatically.

**Requirements:**
- Capture container CPU usage
- Capture container memory usage
- Add a timestamp to each log entry
- Store logs in `/opt/container-monitor/logs/`
- Automate monitoring using a cron job that runs every minute

---

## Part A -- Basic Shell Script Monitoring

### Step 1 -- Create Monitoring Directory

```bash
sudo mkdir -p /opt/container-monitor/logs
```

### Step 2 -- Create the Monitoring Script

```bash
sudo nano /opt/container-monitor/monitor.sh
```

Paste the contents of `monitor.sh` from this directory, then make it executable:

```bash
sudo chmod +x /opt/container-monitor/monitor.sh
```

### Step 3 -- Test Manually

Run the script once to confirm it works:

```bash
sudo /opt/container-monitor/monitor.sh
```

Check the log output:

```bash
cat /opt/container-monitor/logs/container-monitor.log
```

Expected log output:

```
[2025-01-15 14:32:01] CONTAINER: cwl-webapp | CPU: 0.10% | MEM: 5.21MiB / 1.938GiB (0.26%)
```


Each line contains a timestamp, the container name, current CPU percentage, and memory usage with percentage.

### Step 4 -- Automate with Cron (Every Minute)

Open the root crontab:

```bash
sudo crontab -e
```

Add this line at the bottom:

```
* * * * * /opt/container-monitor/monitor.sh
```

Verify the cron entry was saved:

```bash
sudo crontab -l
```

Wait one minute, then tail the log to confirm entries are being written automatically:

```bash
tail -f /opt/container-monitor/logs/container-monitor.log
```
<img width="838" height="546" alt="image" src="https://github.com/user-attachments/assets/363b48d5-8d0a-4e5b-9210-eaab431ac1e4" />

**Expected Outcome:** A new timestamped line appears in the log every minute without any manual intervention.

---

## Part B -- Advanced Grafana + Prometheus Stack


The advanced stack includes:
- **cAdvisor** — collects container resource metrics
- **Prometheus** — scrapes and stores metrics
- **Grafana** — visualises metrics with dashboards
- **Alertmanager** — sends email alerts when CPU or memory exceeds 80% for more than 1 minute

### Architecture

```
Docker Containers
       |
   cAdvisor --> Prometheus --> Grafana --> Dashboard + Alerts
                    |
              node-exporter
                    
```

---

## Files

| File | Purpose |
|------|---------|
| `monitor.sh` | Basic cron monitoring script |
| `docker-compose.yml` | Grafana + Prometheus monitoring stack |
| `prometheus/prometheus.yml` | Prometheus scrape configuration |

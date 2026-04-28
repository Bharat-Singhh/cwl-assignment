# Task 3 -- Container Monitoring

## Objective
Two layers of monitoring:
- Basic: shell script logs CPU and memory every minute via cron
- Advanced: Grafana + Prometheus + cAdvisor with email alerts when
  CPU or memory exceeds 80% for more than 1 minute

---

## Part A -- Basic Shell Script Monitoring

### 1. Create monitoring directory

`ash
sudo mkdir -p /opt/container-monitor/logs
`

### 2. Create the monitoring script

`ash
sudo nano /opt/container-monitor/monitor.sh
# Paste the contents of monitor.sh from this directory
sudo chmod +x /opt/container-monitor/monitor.sh
`

### 3. Test manually

`ash
sudo /opt/container-monitor/monitor.sh
cat /opt/container-monitor/logs/container-monitor.log
`

Expected log output:
`
[2025-01-15 14:32:01] CONTAINER: cwl-webapp | CPU: 0.10% | MEM: 5.21MiB / 1.938GiB (0.26%)
`

### 4. Automate with cron (every minute)

`ash
sudo crontab -e
# Add this line at the bottom:
* * * * * /opt/container-monitor/monitor.sh
`

Verify:
`ash
sudo crontab -l
# Wait 1 minute then check:
tail -f /opt/container-monitor/logs/container-monitor.log
`

---

## Part B -- Advanced Grafana + Prometheus Stack

### Architecture
`
Docker Containers
       |
   cAdvisor --> Prometheus --> Grafana --> Dashboard + Alerts
                    |
              node-exporter
                    |
              Alertmanager --> Email Notifications
`

### 1. Create stack directory on VM

`ash
mkdir -p ~/monitoring-stack/prometheus
mkdir -p ~/monitoring-stack/alertmanager
cd ~/monitoring-stack
`

### 2. Copy config files from this directory to the VM

- docker-compose.yml      -> ~/monitoring-stack/
- prometheus/prometheus.yml -> ~/monitoring-stack/prometheus/
- alertmanager/alertmanager.yml -> ~/monitoring-stack/alertmanager/

### 3. Start the stack

`ash
cd ~/monitoring-stack
docker compose up -d
docker compose ps
`

### 4. Access URLs

| Service | URL |
|---------|-----|
| Grafana | http://VM-IP:3000  (admin/admin) |
| Prometheus | http://VM-IP:9090 |
| cAdvisor | http://VM-IP:8080 |
| Alertmanager | http://VM-IP:9093 |

### 5. Add Prometheus Data Source in Grafana

1. Configuration -> Data Sources -> Add -> Prometheus
2. URL: http://prometheus:9090
3. Save and Test

### 6. Import Dashboard

1. Dashboards -> Import
2. Enter ID 14282 (cAdvisor) or 1860 (Node Exporter Full)
3. Select Prometheus data source -> Import

### 7. Alert Rules (80% threshold for 1 minute)

Go to Grafana -> Alerting -> Alert Rules -> New alert rule

CPU Alert:
`
(rate(container_cpu_usage_seconds_total{name="cwl-webapp"}[1m]) * 100) > 80
`

Memory Alert:
`
(container_memory_usage_bytes{name="cwl-webapp"} /
 container_spec_memory_limit_bytes{name="cwl-webapp"} * 100) > 80
`

Set both to fire when the condition is true for 1 minute.

### 8. Email Notification Setup

- Alerting -> Contact Points -> New Contact Point -> Email
- Enter recipient email
- Update SMTP credentials in docker-compose.yml environment variables

---

## Files
| File | Purpose |
|------|---------|
| monitor.sh | Basic cron monitoring script |
| docker-compose.yml | Grafana + Prometheus monitoring stack |
| prometheus/prometheus.yml | Prometheus scrape configuration |
| alertmanager/alertmanager.yml | Email alert configuration |

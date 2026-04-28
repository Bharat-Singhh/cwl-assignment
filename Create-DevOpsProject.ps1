# ================================================================
#  Create-DevOpsProject.ps1  --  Windows PowerShell
#  Save this file anywhere, then in VS Code PowerShell terminal:
#      cd "folder where this script is saved"
#      .\Create-DevOpsProject.ps1
# ================================================================

# Helper: create a file and all parent folders
function MakeFile($relativePath, $content) {
    $fullPath = Join-Path $PSScriptRoot $relativePath
    $folder   = Split-Path $fullPath
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
    Set-Content -Path $fullPath -Value $content -Encoding UTF8
    Write-Host "  Created: $relativePath" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Building Project-Submission..." -ForegroundColor Cyan
Write-Host ""

# ================================================================
# ROOT README
# ================================================================
MakeFile "Project-Submission\README.md" @"
# CWL DevOps Internship -- Project Submission

## Overview
Complete submission for the CWL DevOps Intern assignment covering:
- Secure server provisioning on Ubuntu 22.04 (VirtualBox)
- Containerised web app deployment via Docker Hub
- Automated container monitoring with cron + Grafana stack
- User access control for monitoring directory
- UFW firewall hardening

## Architecture
```
Windows Host
|
+-- VirtualBox --> Ubuntu 22.04 VM  (192.168.x.x)
                      |
                      +-- SSH (port 22)  <-- PuTTY key-based auth
                      |
                      +-- Docker Engine
                      |     +-- cwl-webapp      (port 8000 -> nginx:80)
                      |     +-- prometheus       (port 9090)
                      |     +-- grafana          (port 3000)
                      |     +-- cadvisor         (port 8080)
                      |     +-- node-exporter    (port 9100)
                      |     +-- alertmanager     (port 9093)
                      |
                      +-- cron --> /opt/container-monitor/logs/
                      +-- UFW firewall
|
+-- Docker Hub --> custom nginx image
```

## Repository Structure
| Folder | Topic |
|--------|-------|
| Task-1 | Server Setup and SSH Configuration |
| Task-2 | Docker Installation and App Deployment |
| Task-3 | Container Monitoring (cron script + Grafana stack) |
| Task-4 | Secure Monitoring Logs / User Permissions |
| Task-5 | Firewall Configuration (UFW) |

## Environment
| Item | Value |
|------|-------|
| Host OS | Windows |
| Guest OS | Ubuntu 22.04 LTS |
| SSH Client | PuTTY + PuTTYgen |
| Container Runtime | Docker Engine (latest) |
| Monitoring | Prometheus, Grafana, cAdvisor, Node Exporter, Alertmanager |
| Firewall | UFW |
"@

# ================================================================
# TASK 1
# ================================================================
MakeFile "Project-Submission\Task-1\README.md" @"
# Task 1 -- Server Setup and SSH Configuration

## Objective
Provision an Ubuntu 22.04 server inside VirtualBox and configure
passwordless SSH access using key-based authentication.

---

## Step 1 -- Provision the Virtual Machine

| Setting | Value |
|---------|-------|
| Hypervisor | Oracle VirtualBox |
| OS | Ubuntu 22.04 LTS Server |
| RAM | 2 GB |
| Disk | 20 GB (dynamically allocated) |
| Network | Bridged Adapter |

After first boot, get the VM IP:
```bash
ip a
```

---

## Step 2 -- Install and Enable OpenSSH Server

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
```

---

## Step 3 -- Generate SSH Key Pair with PuTTYgen (on Windows)

1. Opened PuTTYgen
2. Key type: RSA, Bits: 4096
3. Clicked Generate and moved mouse to create randomness
4. Clicked Save private key -> saved as devops-intern.ppk
5. Copied the public key text from the top box

---

## Step 4 -- Install Public Key on the Server

```bash
# On the Ubuntu VM (logged in with password for now)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-rsa AAAA...YOUR-PUBLIC-KEY... devops-intern-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

---

## Step 5 -- Configure PuTTY to Use the Private Key

1. Opened PuTTY -> entered VM IP in Host Name field
2. Navigated to Connection -> SSH -> Auth -> Credentials
3. Browsed to devops-intern.ppk and selected it
4. Saved the session as Ubuntu-DevOps
5. Clicked Open -- logged in without a password prompt

---

## Step 6 -- Disable Password Authentication

```bash
sudo nano /etc/ssh/sshd_config
```

Updated these lines:
```
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

```bash
sudo systemctl restart ssh

# Verify
sudo sshd -T | grep passwordauthentication
# Expected: passwordauthentication no
```

---

## Expected Outcome
- SSH login works with private key, no password prompt
- Password-based SSH is blocked
- Root SSH login is disabled
"@

# ================================================================
# TASK 2
# ================================================================
MakeFile "Project-Submission\Task-2\README.md" @"
# Task 2 -- Docker Installation and Application Deployment

## Objective
Build a custom Docker image from index.html, push to Docker Hub,
install Docker on the VM, and run the container on port 8000.

---

## Step 1 -- Build Docker Image Locally (Windows)

The index.html was provided with the assignment.
The Dockerfile was created locally in the same folder.

```bash
docker build -t YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest .
```

Test locally (optional):
```bash
docker run -d -p 8000:80 YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
# Open browser: http://localhost:8000
```

---

## Step 2 -- Push to Docker Hub

```bash
docker login
docker push YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
```

---

## Step 3 -- Install Docker on Ubuntu VM

```bash
# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify
docker --version
sudo systemctl enable docker
```

---

## Step 4 -- Allow Current User to Run Docker Without sudo

```bash
sudo usermod -aG docker \$USER
newgrp docker
```

---

## Step 5 -- Pull Image and Run Container

```bash
docker pull YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest

docker run -d \
  --name cwl-webapp \
  --restart unless-stopped \
  -p 8000:80 \
  YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest

# Verify
docker ps
```

---

## Step 6 -- Verify in Browser

```bash
# From VM terminal
curl http://localhost:8000

# From Windows browser
# http://VM-IP-ADDRESS:8000
```

---

## Files
| File | Purpose |
|------|---------|
| Dockerfile | Used to build the web app image |
"@

MakeFile "Project-Submission\Task-2\Dockerfile" @"
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
"@

# ================================================================
# TASK 3
# ================================================================
MakeFile "Project-Submission\Task-3\README.md" @"
# Task 3 -- Container Monitoring

## Objective
Two layers of monitoring:
- Basic: shell script logs CPU and memory every minute via cron
- Advanced: Grafana + Prometheus + cAdvisor with email alerts when
  CPU or memory exceeds 80% for more than 1 minute

---

## Part A -- Basic Shell Script Monitoring

### 1. Create monitoring directory

```bash
sudo mkdir -p /opt/container-monitor/logs
```

### 2. Create the monitoring script

```bash
sudo nano /opt/container-monitor/monitor.sh
# Paste the contents of monitor.sh from this directory
sudo chmod +x /opt/container-monitor/monitor.sh
```

### 3. Test manually

```bash
sudo /opt/container-monitor/monitor.sh
cat /opt/container-monitor/logs/container-monitor.log
```

Expected log output:
```
[2025-01-15 14:32:01] CONTAINER: cwl-webapp | CPU: 0.10% | MEM: 5.21MiB / 1.938GiB (0.26%)
```

### 4. Automate with cron (every minute)

```bash
sudo crontab -e
# Add this line at the bottom:
* * * * * /opt/container-monitor/monitor.sh
```

Verify:
```bash
sudo crontab -l
# Wait 1 minute then check:
tail -f /opt/container-monitor/logs/container-monitor.log
```

---

## Part B -- Advanced Grafana + Prometheus Stack

### Architecture
```
Docker Containers
       |
   cAdvisor --> Prometheus --> Grafana --> Dashboard + Alerts
                    |
              node-exporter
                    |
              Alertmanager --> Email Notifications
```

### 1. Create stack directory on VM

```bash
mkdir -p ~/monitoring-stack/prometheus
mkdir -p ~/monitoring-stack/alertmanager
cd ~/monitoring-stack
```

### 2. Copy config files from this directory to the VM

- docker-compose.yml      -> ~/monitoring-stack/
- prometheus/prometheus.yml -> ~/monitoring-stack/prometheus/
- alertmanager/alertmanager.yml -> ~/monitoring-stack/alertmanager/

### 3. Start the stack

```bash
cd ~/monitoring-stack
docker compose up -d
docker compose ps
```

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
```
(rate(container_cpu_usage_seconds_total{name="cwl-webapp"}[1m]) * 100) > 80
```

Memory Alert:
```
(container_memory_usage_bytes{name="cwl-webapp"} /
 container_spec_memory_limit_bytes{name="cwl-webapp"} * 100) > 80
```

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
"@

MakeFile "Project-Submission\Task-3\monitor.sh" @"
#!/bin/bash
# monitor.sh
# Logs CPU and memory usage of all running containers with timestamps.
# Scheduled to run every minute via cron.

LOG_DIR="/opt/container-monitor/logs"
LOG_FILE="\$LOG_DIR/container-monitor.log"

mkdir -p "\$LOG_DIR"

TIMESTAMP=\$(date "+%Y-%m-%d %H:%M:%S")

docker stats --no-stream --format \
  "{{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.MemPerc}}" \
| while read -r name cpu mem_usage mem_perc; do
    echo "[\$TIMESTAMP] CONTAINER: \$name | CPU: \$cpu | MEM: \$mem_usage (\$mem_perc)"
done >> "\$LOG_FILE"

if ! docker ps -q | grep -q .; then
    echo "[\$TIMESTAMP] No running containers detected." >> "\$LOG_FILE"
fi
"@

MakeFile "Project-Submission\Task-3\docker-compose.yml" @"
version: '3.8'

services:

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    restart: always

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SMTP_ENABLED=true
      - GF_SMTP_HOST=smtp.gmail.com:587
      - GF_SMTP_USER=your@gmail.com
      - GF_SMTP_PASSWORD=your-app-password
      - GF_SMTP_FROM_ADDRESS=your@gmail.com
    volumes:
      - grafana-data:/var/lib/grafana
    restart: always

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    privileged: true
    devices:
      - /dev/kmsg
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: always

  node-exporter:
    image: prom/node-exporter
    container_name: node-exporter
    ports:
      - "9100:9100"
    restart: always

  alertmanager:
    image: prom/alertmanager
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    restart: always

volumes:
  grafana-data:
"@

MakeFile "Project-Submission\Task-3\prometheus\prometheus.yml" @"
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
"@

MakeFile "Project-Submission\Task-3\alertmanager\alertmanager.yml" @"
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'your@gmail.com'
  smtp_auth_username: 'your@gmail.com'
  smtp_auth_password: 'your-app-password'
  smtp_require_tls: true

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: 'email-alert'

receivers:
  - name: 'email-alert'
    email_configs:
      - to: 'your@gmail.com'
        send_resolved: true
"@

# ================================================================
# TASK 4
# ================================================================
MakeFile "Project-Submission\Task-4\README.md" @"
# Task 4 -- Secure Monitoring Logs (User Access Control)

## Objective
Create a dedicated admin user who owns the monitoring directory with
full access. All other users are completely restricted.

Note: Task 4 was done before Task 3 so the directory was already
secured before the monitoring script and cron job were configured.

---

## Step 1 -- Create the admin User

```bash
sudo adduser admin
```

Add admin to the docker group so the monitoring script can query
docker stats without sudo:
```bash
sudo usermod -aG docker admin
```

---

## Step 2 -- Create the Monitoring Directory

```bash
sudo mkdir -p /opt/container-monitor/logs
```

---

## Step 3 -- Assign Ownership to admin

```bash
sudo chown -R admin:admin /opt/container-monitor
```

---

## Step 4 -- Set Permissions (owner full, others none)

```bash
sudo chmod -R 700 /opt/container-monitor

# Verify
ls -ld /opt/container-monitor
ls -ld /opt/container-monitor/logs
```

Expected output:
```
drwx------ 3 admin admin 4096 Jan 15 14:00 /opt/container-monitor
drwx------ 2 admin admin 4096 Jan 15 14:00 /opt/container-monitor/logs
```

---

## Step 5 -- Run Cron Job as admin

```bash
sudo crontab -u admin -e
# Add:
* * * * * /opt/container-monitor/monitor.sh

# Verify
sudo crontab -u admin -l
```

---

## Step 6 -- Verify Access Controls

admin access (should succeed):
```bash
sudo -u admin ls /opt/container-monitor/logs
sudo -u admin cat /opt/container-monitor/logs/container-monitor.log
```

Other user access (should be denied):
```bash
sudo -u OTHER-USERNAME ls /opt/container-monitor
# Expected: Permission denied
```

---

## Access Summary
| User | Access |
|------|--------|
| admin | Full (rwx) |
| Other users | None -- Permission denied |
| root | Full |

---

## Files
| File | Purpose |
|------|---------|
| permissions-setup.sh | Reproduces all permission commands |
"@

MakeFile "Project-Submission\Task-4\permissions-setup.sh" @"
#!/bin/bash
# permissions-setup.sh
# Reproduces the full user and permission setup for Task 4.

set -e

echo "==> Creating admin user..."
sudo adduser --disabled-password --gecos "" admin || echo "User already exists."

echo "==> Adding admin to docker group..."
sudo usermod -aG docker admin

echo "==> Creating monitoring directories..."
sudo mkdir -p /opt/container-monitor/logs

echo "==> Assigning ownership to admin..."
sudo chown -R admin:admin /opt/container-monitor

echo "==> Setting permissions (700 -- owner only)..."
sudo chmod -R 700 /opt/container-monitor

echo "==> Verifying..."
ls -ld /opt/container-monitor
ls -ld /opt/container-monitor/logs

echo ""
echo "Done. admin has full access. All other users are restricted."
"@

# ================================================================
# TASK 5
# ================================================================
MakeFile "Project-Submission\Task-5\README.md" @"
# Task 5 -- Firewall Configuration (UFW)

## Objective
Configure UFW to:
- Allow SSH only from a trusted (specific) IP address
- Allow HTTP on port 80
- Allow web app traffic on port 8000
- Block everything else by default

---

## Step 1 -- Install UFW

```bash
sudo apt update
sudo apt install -y ufw
```

---

## Step 2 -- Set Default Policies

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

---

## Step 3 -- Allow SSH from Specific IP Only

Run ipconfig on Windows to find your host IP, then:

```bash
sudo ufw allow from YOUR-WINDOWS-IP to any port 22
# Example: sudo ufw allow from 192.168.1.50 to any port 22
```

---

## Step 4 -- Allow HTTP (Port 80)

```bash
sudo ufw allow 80/tcp
```

---

## Step 5 -- Allow Port 8000 (Web App)

```bash
sudo ufw allow 8000/tcp
```

---

## Step 6 -- Enable UFW

Ensure your SSH session is active before running this:

```bash
sudo ufw enable
# Type y when prompted
```

---

## Step 7 -- Verify Rules

```bash
sudo ufw status verbose
```

Expected output:
```
Status: active
Default: deny (incoming), allow (outgoing)

To                    Action      From
--                    ------      ----
22                    ALLOW IN    YOUR-WINDOWS-IP
80/tcp                ALLOW IN    Anywhere
8000/tcp              ALLOW IN    Anywhere
```

---

## Step 8 -- Testing

SSH from allowed IP (should connect normally via PuTTY).

Web app access:
```bash
curl http://VM-IP:8000
# Expected: HTML from index.html
```

SSH from any other IP will time out (blocked).

---

## Files
| File | Purpose |
|------|---------|
| firewall-setup.sh | Script to reproduce all UFW commands |
"@

MakeFile "Project-Submission\Task-5\firewall-setup.sh" @"
#!/bin/bash
# firewall-setup.sh
# Reproduces the UFW firewall configuration for Task 5.
# Update YOUR_HOST_IP before running.

set -e

YOUR_HOST_IP="192.168.1.50"   # <-- Change to your Windows machine IP

sudo apt update -q
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from "\$YOUR_HOST_IP" to any port 22
sudo ufw allow 80/tcp
sudo ufw allow 8000/tcp
sudo ufw --force enable
sudo ufw status verbose
"@

# ================================================================
# SUMMARY
# ================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Done! All files created successfully." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Folder: $PSScriptRoot\Project-Submission" -ForegroundColor Cyan
Write-Host ""
Write-Host "Structure:" -ForegroundColor Yellow
Get-ChildItem -Path (Join-Path $PSScriptRoot "Project-Submission") -Recurse | ForEach-Object {
    $depth  = ($_.FullName.Split('\').Count) - ($PSScriptRoot.Split('\').Count) - 1
    $indent = "  " * $depth
    Write-Host "$indent$($_.Name)"
}
Write-Host ""
Write-Host "Fill in lines marked YOUR-... in each README, then:" -ForegroundColor Yellow
Write-Host "  git init / git add . / git commit / git push" -ForegroundColor White
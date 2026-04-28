# CWL DevOps Internship -- Project Submission

## Overview
Complete submission for the CWL DevOps Intern assignment covering:
- Secure server provisioning on Ubuntu 22.04 (VirtualBox)
- Containerised web app deployment via Docker Hub
- Automated container monitoring with cron + Grafana stack
- User access control for monitoring directory
- UFW firewall hardening

## Architecture
`
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
`

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

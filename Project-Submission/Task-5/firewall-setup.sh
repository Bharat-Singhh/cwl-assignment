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
sudo ufw allow from "\" to any port 22
sudo ufw allow 80/tcp
sudo ufw allow 8000/tcp
sudo ufw --force enable
sudo ufw status verbose

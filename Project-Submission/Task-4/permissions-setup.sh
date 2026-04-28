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

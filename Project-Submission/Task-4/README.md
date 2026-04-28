# Task 4 -- Secure Monitoring Logs (User Access Control)

## Objective
Create a dedicated admin user who owns the monitoring directory with
full access. All other users are completely restricted.

Note: Task 4 was done before Task 3 so the directory was already
secured before the monitoring script and cron job were configured.

---

## Step 1 -- Create the admin User

`ash
sudo adduser admin
`

Add admin to the docker group so the monitoring script can query
docker stats without sudo:
`ash
sudo usermod -aG docker admin
`

---

## Step 2 -- Create the Monitoring Directory

`ash
sudo mkdir -p /opt/container-monitor/logs
`

---

## Step 3 -- Assign Ownership to admin

`ash
sudo chown -R admin:admin /opt/container-monitor
`

---

## Step 4 -- Set Permissions (owner full, others none)

`ash
sudo chmod -R 700 /opt/container-monitor

# Verify
ls -ld /opt/container-monitor
ls -ld /opt/container-monitor/logs
`

Expected output:
`
drwx------ 3 admin admin 4096 Jan 15 14:00 /opt/container-monitor
drwx------ 2 admin admin 4096 Jan 15 14:00 /opt/container-monitor/logs
`

---

## Step 5 -- Run Cron Job as admin

`ash
sudo crontab -u admin -e
# Add:
* * * * * /opt/container-monitor/monitor.sh

# Verify
sudo crontab -u admin -l
`

---

## Step 6 -- Verify Access Controls

admin access (should succeed):
`ash
sudo -u admin ls /opt/container-monitor/logs
sudo -u admin cat /opt/container-monitor/logs/container-monitor.log
`

Other user access (should be denied):
`ash
sudo -u OTHER-USERNAME ls /opt/container-monitor
# Expected: Permission denied
`

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

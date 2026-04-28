# Task 4 -- Secure Monitoring Logs (User Access Control)

## Objective

Create a dedicated `admin` user who owns the monitoring directory with full access. All other users are completely restricted.

> **Note:** Task 4 was completed before Task 3, so the directory was already secured before the monitoring script and cron job were configured.

---

## Step 1 -- Create the admin User

```bash
sudo adduser admin
```

Add `admin` to the `docker` group so the monitoring script can query `docker stats` without needing `sudo`:

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
```

Verify the permissions were applied correctly:

```bash
ls -ld /opt/container-monitor
```

```bash
ls -ld /opt/container-monitor/logs
```

Expected output:

```
drwx------ 3 admin admin 4096 Jan 15 14:00 /opt/container-monitor
drwx------ 2 admin admin 4096 Jan 15 14:00 /opt/container-monitor/logs
```

The `700` permission means the owner (`admin`) has full read, write, and execute access while all other users have no access at all.

---

## Step 5 -- Run Cron Job as admin

Open the crontab for the `admin` user:

```bash
sudo crontab -u admin -e
```

Add this line at the bottom:

```
* * * * * /opt/container-monitor/monitor.sh
```

Verify the entry was saved:

```bash
sudo crontab -u admin -l
```

---

## Step 6 -- Verify Access Controls

Confirm `admin` can access the directory and logs:

```bash
sudo -u admin ls /opt/container-monitor/logs
```

```bash
sudo -u admin cat /opt/container-monitor/logs/container-monitor.log
```

Confirm all other users are blocked:

```bash
sudo -u OTHER-USERNAME ls /opt/container-monitor
```

Expected output:

```
ls: cannot open directory '/opt/container-monitor': Permission denied
```

Replace `OTHER-USERNAME` with any non-admin, non-root user on the system.

---

## Access Summary

| User | Access |
|------|--------|
| `admin` | Full (rwx) |
| Other users | None — Permission denied |
| `root` | Full |

---

## Files

| File | Purpose |
|------|---------|
| `permissions-setup.sh` | Reproduces all permission commands from this task |

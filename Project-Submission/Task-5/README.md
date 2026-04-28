# Task 5 -- Firewall Configuration (UFW)

## Objective
Configure UFW to:
- Allow SSH only from a trusted (specific) IP address
- Allow HTTP on port 80
- Allow web app traffic on port 8000
- Block everything else by default

---

## Step 1 -- Install UFW

`ash
sudo apt update
sudo apt install -y ufw
`

---

## Step 2 -- Set Default Policies

`ash
sudo ufw default deny incoming
sudo ufw default allow outgoing
`

---

## Step 3 -- Allow SSH from Specific IP Only

Run ipconfig on Windows to find your host IP, then:

`ash
sudo ufw allow from YOUR-WINDOWS-IP to any port 22
# Example: sudo ufw allow from 192.168.1.50 to any port 22
`

---

## Step 4 -- Allow HTTP (Port 80)

`ash
sudo ufw allow 80/tcp
`

---

## Step 5 -- Allow Port 8000 (Web App)

`ash
sudo ufw allow 8000/tcp
`

---

## Step 6 -- Enable UFW

Ensure your SSH session is active before running this:

`ash
sudo ufw enable
# Type y when prompted
`

---

## Step 7 -- Verify Rules

`ash
sudo ufw status verbose
`

Expected output:
`
Status: active
Default: deny (incoming), allow (outgoing)

To                    Action      From
--                    ------      ----
22                    ALLOW IN    YOUR-WINDOWS-IP
80/tcp                ALLOW IN    Anywhere
8000/tcp              ALLOW IN    Anywhere
`

---

## Step 8 -- Testing

SSH from allowed IP (should connect normally via PuTTY).

Web app access:
`ash
curl http://VM-IP:8000
# Expected: HTML from index.html
`

SSH from any other IP will time out (blocked).

---

## Files
| File | Purpose |
|------|---------|
| firewall-setup.sh | Script to reproduce all UFW commands |

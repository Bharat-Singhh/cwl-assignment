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
```

```bash
sudo apt install -y ufw
```

---

## Step 2 -- Set Default Policies

Block all incoming traffic by default, and allow all outgoing:

```bash
sudo ufw default deny incoming
```

```bash
sudo ufw default allow outgoing
```

---

## Step 3 -- Allow SSH from Specific IP Only

On your Windows machine, run `ipconfig` in Command Prompt to find your host IP address. Then allow SSH only from that IP:

```bash
sudo ufw allow from YOUR-WINDOWS-IP to any port 22
```

Example:

```bash
sudo ufw allow from 192.168.1.50 to any port 22
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
## Step 6 -- Allow Port 3000 (Grafana)

```bash
sudo ufw allow 3000/tcp
```


---

## Step 7 -- Enable UFW

Make sure your SSH session is still active, then enable the firewall:

```bash
sudo ufw enable
```

Type `y` when prompted. The rules configured in the previous steps will take effect immediately.

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

**SSH from allowed IP** — connect normally via PuTTY using the trusted IP. The session should open without issues.

**Web app from browser** — open `http://VM-IP:8000` in your browser. Expected response is the HTML from `index.html`.

**Curl test from VM terminal:**

```bash
curl http://VM-IP:8000
```

**SSH from any other IP** — the connection will time out. UFW silently drops packets from untrusted sources, so no error is shown — the connection simply never completes.

---

## Files

| File | Purpose |
|------|---------|
| `firewall-setup.sh` | Script to reproduce all UFW commands from this task |

# Task 1 -- Server Setup and SSH Configuration

## Objective

Provision an Ubuntu 22.04 server inside VirtualBox and configure passwordless SSH access using key-based authentication. By the end of this task, SSH login will work exclusively through a private key, password-based authentication will be disabled, and root SSH access will be blocked.

---

## Step 1 -- Provision the Virtual Machine

| Setting | Value |
|---------|-------|
| Hypervisor | Oracle VirtualBox |
| OS | Ubuntu 22.04 LTS Server |
| RAM | 2 GB |
| Disk | 20 GB (dynamically allocated) |
| Network | Bridged Adapter |

After first boot, get the VM IP address by running:

```bash
ip a
```

Look for the `inet` address under your active network interface (e.g., `enp0s3`). You will need this IP in later steps to connect via SSH.

---

## Step 2 -- Install and Enable OpenSSH Server

Install the OpenSSH server, enable it to start on boot, and verify it is running:

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
sudo apt install -y openssh-server
```

```bash
sudo systemctl enable ssh
```

```bash
sudo systemctl start ssh
```

```bash
sudo systemctl status ssh
```

The status output should show `active (running)`. If the service is not running, check for errors with `journalctl -xe`.

---

## Step 3 -- Generate SSH Key Pair with PuTTYgen (on Windows)

1. Open PuTTYgen (download from putty.org if not already installed)
2. Set Key type to **RSA** and Bits to **4096**
3. Click **Generate** and move the mouse randomly over the blank area to create entropy
4. Click **Save private key** and save the file as `devops-intern.ppk` — keep this file secure, it is your private key
5. Copy the entire public key text from the top box (starts with `ssh-rsa`) — you will paste this on the server in the next step

---

## Step 4 -- Install Public Key on the Server

While still logged in to the VM with a password, add the public key to the `authorized_keys` file:

```bash
mkdir -p ~/.ssh
```

```bash
chmod 700 ~/.ssh
```

```bash
echo "ssh-rsa AAAA...YOUR-PUBLIC-KEY... devops-intern-key" >> ~/.ssh/authorized_keys
```

```bash
chmod 600 ~/.ssh/authorized_keys
```

> Replace `AAAA...YOUR-PUBLIC-KEY...` with the actual public key text copied from PuTTYgen. The permissions (700 on the directory, 600 on the file) are required — SSH will refuse to use the key if permissions are too permissive.

---

## Step 5 -- Configure PuTTY to Use the Private Key

1. Open PuTTY and enter the VM's IP address in the **Host Name** field
2. In the left panel, navigate to **Connection → SSH → Auth → Credentials**
3. Under **Private key file for authentication**, click Browse and select `devops-intern.ppk`
4. Go back to **Session**, type `Ubuntu-DevOps` in the **Saved Sessions** box, and click **Save**
5. Click **Open** — you should be logged in without any password prompt

---

## Step 6 -- Disable Password Authentication

Once key-based login is confirmed working, harden the server by disabling password authentication and blocking root SSH access:

```bash
sudo nano /etc/ssh/sshd_config
```

Find and update (or add) the following lines:

```
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

Save the file (`Ctrl+O`, then `Enter`, then `Ctrl+X`), then restart SSH and verify the change:

```bash
sudo systemctl restart ssh
```

```bash
sudo sshd -T | grep passwordauthentication
```

Expected output: `passwordauthentication no`

---

<img width="582" height="193" alt="image" src="https://github.com/user-attachments/assets/8928a705-9fb8-457f-a822-85ffcb68b7cd" />


## Expected Outcome

- SSH login works with the private key — no password prompt
- Password-based SSH login is blocked
- Root SSH login is disabled
- 
<img width="876" height="572" alt="image" src="https://github.com/user-attachments/assets/266dbd7b-1994-4ed7-adb9-4541261af3bd" />

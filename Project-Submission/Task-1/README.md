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
`ash
ip a
`

---

## Step 2 -- Install and Enable OpenSSH Server

`ash
sudo apt update && sudo apt upgrade -y
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
sudo systemctl status ssh
`

---

## Step 3 -- Generate SSH Key Pair with PuTTYgen (on Windows)

1. Opened PuTTYgen
2. Key type: RSA, Bits: 4096
3. Clicked Generate and moved mouse to create randomness
4. Clicked Save private key -> saved as devops-intern.ppk
5. Copied the public key text from the top box

---

## Step 4 -- Install Public Key on the Server

`ash
# On the Ubuntu VM (logged in with password for now)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "ssh-rsa AAAA...YOUR-PUBLIC-KEY... devops-intern-key" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
`

---

## Step 5 -- Configure PuTTY to Use the Private Key

1. Opened PuTTY -> entered VM IP in Host Name field
2. Navigated to Connection -> SSH -> Auth -> Credentials
3. Browsed to devops-intern.ppk and selected it
4. Saved the session as Ubuntu-DevOps
5. Clicked Open -- logged in without a password prompt

---

## Step 6 -- Disable Password Authentication

`ash
sudo nano /etc/ssh/sshd_config
`

Updated these lines:
`
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
`

`ash
sudo systemctl restart ssh

# Verify
sudo sshd -T | grep passwordauthentication
# Expected: passwordauthentication no
`

---

## Expected Outcome
- SSH login works with private key, no password prompt
- Password-based SSH is blocked
- Root SSH login is disabled

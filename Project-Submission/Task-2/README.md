# Task 2 -- Docker Installation and Application Deployment

## Objective
Build a custom Docker image from index.html, push to Docker Hub,
install Docker on the VM, and run the container on port 8000.

---

## Step 1 -- Build Docker Image Locally (Windows)

The index.html was provided with the assignment.
The Dockerfile was created locally in the same folder.

`ash
docker build -t YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest .
`

Test locally (optional):
`ash
docker run -d -p 8000:80 YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
# Open browser: http://localhost:8000
`

---

## Step 2 -- Push to Docker Hub

`ash
docker login
docker push YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
`

---

## Step 3 -- Install Docker on Ubuntu VM

`ash
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
  "deb [arch= signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
   stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify
docker --version
sudo systemctl enable docker
`

---

## Step 4 -- Allow Current User to Run Docker Without sudo

`ash
sudo usermod -aG docker \
newgrp docker
`

---

## Step 5 -- Pull Image and Run Container

`ash
docker pull YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest

docker run -d \
  --name cwl-webapp \
  --restart unless-stopped \
  -p 8000:80 \
  YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest

# Verify
docker ps
`

---

## Step 6 -- Verify in Browser

`ash
# From VM terminal
curl http://localhost:8000

# From Windows browser
# http://VM-IP-ADDRESS:8000
`

---

## Files
| File | Purpose |
|------|---------|
| Dockerfile | Used to build the web app image |

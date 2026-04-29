# Task 2 -- Docker Installation and Application Deployment

## Objective

Build a custom Docker image from `index.html`, push it to Docker Hub, install Docker on the Ubuntu VM, and run the container on port 8000.

---

## Step 1 -- Build Docker Image Locally (Windows) usng dockerfile
```
﻿FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

The `index.html` was provided with the assignment. The `Dockerfile` was created locally in the same folder as `index.html`.

Build the image:

```bash
docker build -t YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest .
```

Test locally (optional):

```bash
docker run -d -p 8000:80 YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
```

Open `http://localhost:8000` in your browser to verify it works before pushing.

---

<img width="1162" height="810" alt="image" src="https://github.com/user-attachments/assets/f378f54f-bee1-4640-9d5b-e63684f767e5" />


## Step 2 -- Push to Docker Hub

Log in to Docker Hub and push the image:

```bash
docker login
```

```bash
docker push YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
```

---
<img width="896" height="641" alt="image" src="https://github.com/user-attachments/assets/47781661-b1b7-4b86-b7f0-1035689a1b88" />


## Step 3 -- Install Docker on Ubuntu VM

Run the following commands in order to install Docker Engine on the VM:

```bash
sudo apt remove -y docker docker-engine docker.io containerd runc
```

```bash
sudo apt update
```

```bash
sudo apt install -y ca-certificates curl gnupg lsb-release
```

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```bash
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```bash
sudo apt update
```

```bash
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Verify the installation:

```bash
docker --version
```

```bash
sudo systemctl enable docker
```

---


## Step 4 -- Pull Image and Run Container

Pull the image from Docker Hub and start the container:

```bash
docker pull YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
```

```bash
docker run -d --name cwl-webapp --restart unless-stopped -p 8000:80 YOUR-DOCKERHUB-USERNAME/cwl-webapp:latest
```

Verify the container is running:

```bash
docker ps
```

---

## Step 5 -- Verify in Browser

Check the app is responding from the VM terminal:

```bash
curl http://localhost:8000
```

Then open a browser on your Windows machine and navigate to:

```
http://VM-IP-ADDRESS:8000
```

Replace `VM-IP-ADDRESS` with the IP you noted in Task 1 Step 1.

---

<img width="1920" height="1032" alt="image" src="https://github.com/user-attachments/assets/27ecd110-bc36-4264-bd4a-51c55ee361b7" />



## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Defines the image — copies `index.html` into an nginx base image |
| `index.html` | The web page served by the container |

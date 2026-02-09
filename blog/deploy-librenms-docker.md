---
layout: default
title: "Deploy LibreNMS with Docker"
---

# Deploy LibreNMS with Docker

LibreNMS is a network monitoring system that can be easily deployed using Docker. This guide will help you set up LibreNMS using Docker Compose, allowing you to monitor network devices with SNMP and other protocols.

First, update your package list and install the unzip package.

```bash
sudo apt update
sudo apt install unzip -y
```

Download and unzip the file.

```bash
wget https://github.com/librenms/docker/archive/refs/heads/master.zip
unzip master.zip
```

Copy the Docker compose files.

```bash
cp -r docker-master/examples/compose librenms
cd librenms
```

Bring up the Docker containers.

```bash
docker compose up -d
```

Open your web browser and navigate to `http://localhost:8000` to complete the setup. Replace `localhost` with Docker host's IP address if you're accessing it remotely.

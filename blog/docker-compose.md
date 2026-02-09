---
layout: default
title: "Create containers using Docker Compose"
---

# Create containers using Docker Compose

To clone the repository, run the following command:

```bash
git clone https://github.com/galjabari/cloud-computing.git
```

To run the hands-on labs, open Visual Studio Code using the following commands:

```bash
cd cloud-computing
code .
```

For example, to create and run a WordPress stack using Docker Compose, execute these commands:

```bash
cd wordpress
docker compose up
```

Docker Compose pulls images from Docker Hub, creates containers, and starts the services. You can log in to WordPress by opening a web browser and navigating to `http://localhost:8080`. Replace `localhost` with your Docker host's IP address if you're running it on a remote host.

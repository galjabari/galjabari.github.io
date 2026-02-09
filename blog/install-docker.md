---
layout: default
title: "Install Docker on Ubuntu"
---

# Install Docker on Ubuntu

To get started quickly, you can install Docker using the official script:

```bash
curl -fsSL https://get.docker.com | sh
```

Alternatively, to inspect the script before installation, download it first:

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

After installing, add your user to the `docker` group to run Docker commands without `sudo`:

```bash
sudo usermod -aG docker $USER
```

You may need to log out and log back in for this change to take effect.

Check Docker version:

```bash
docker --version
```

---
layout: default
title: "Install GNS3 on Ubuntu"
---

# Install GNS3 on Ubuntu

This guide provides step-by-step instructions for installing the GNS3 network emulator on Ubuntu, along with essential components like Docker and VNC for full functionality.

First, add the official GNS3 repository to get the latest version:

```
sudo add-apt-repository ppa:gns3/ppa -y
sudo apt update
```

Next, install the GNS3 graphical interface and the server component:

```
sudo apt install gns3-gui gns3-server -y
```

To connect to the graphical console of certain network appliances within GNS3, install a VNC client:

```
sudo apt install tigervnc-standalone-server tigervnc-viewer -y
```

GNS3 can run Docker containers as nodes in your network topologies. Install Docker using the official script:

```
curl -fsSL https://get.docker.com | sh
```

After installation, add your user to the `docker` group to run Docker commands without `sudo`:

```
sudo usermod -aG docker $USER
```

You may need to log out and log back in for this change to take effect.

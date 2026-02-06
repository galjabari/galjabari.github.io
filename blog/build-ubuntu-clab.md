---
layout: default
title: "Build custom Ubuntu node for Containerlab"
---

# Build custom Ubuntu node for Containerlab

This guide explains how to build a custom Ubuntu image for Containerlab. The image allows you to run Ubuntu containers as host nodes in your lab deployments.

First, create a `Dockerfile` to define a custom Ubuntu image. This file pre-installs the necessary networking tools into the image.

```dockerfile
# Use official Ubuntu base image
FROM ubuntu:latest
# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iproute2 \
        iputils-ping \
        net-tools \
        dnsutils \
        wget \
        curl \
        traceroute \
        nano \
        vim \
        sudo \
        gnupg \
        lsb-release \
        python3 \
        python3-pip \
        tcpdump \
        iptables \
        bridge-utils \
        ca-certificates \
        openssh-server \
        isc-dhcp-client \
    && rm -rf /var/lib/apt/lists/*
# Create a 'clab' user with sudo privileges and 'clab' password
RUN useradd -ms /bin/bash clab && echo "clab:clab" | chpasswd && adduser clab sudo
# Set up SSH server
RUN mkdir -p /var/run/sshd && \
    touch /etc/ssh/sshd_config && \
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
# Expose SSH port
EXPOSE 22
# Set working directory
WORKDIR /home/clab
# Set default command to start SSH server
CMD ["/usr/sbin/sshd", "-D"]
```

Once the `Dockerfile` is created, build the Docker image with the following command:

```
docker build -t clab-ubuntu:latest .
```

This command creates a local Docker image named `clab-ubuntu` with the `latest` tag.

Next, define the lab topology in a YAML file. In this example, the lab consists of a client and a server that will use the custom-built Ubuntu image.

Create a file named `ubuntu.clab.yml` and add the following content:

```
name: ubuntu
topology:
  nodes:
    switch:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    client:
      kind: linux
      image: clab-ubuntu:latest
      exec:
        - ip addr add 192.168.10.2/24 dev eth1
    server:
      kind: linux
      image: clab-ubuntu:latest
      exec:
        - ip addr add 192.168.10.3/24 dev eth1
  links:
    - endpoints: ["switch:eth1", "client:eth1"]
    - endpoints: ["switch:eth2", "server:eth1"]    
```

Create the switch configuration file named `switch.cfg`:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
interface Ethernet1
   switchport
!
interface Ethernet2
   switchport
!
end
```

Deploy the lab using Containerlab:

```
clab deploy -t ubuntu.clab.yml
```

After deployment, test the connectivity between the client and the server. Connect to the client:

```
ssh clab@clab-ubuntu-client
```

Ping the server from the client:

```
ping 192.168.10.3
```

To destroy the lab and remove all containers, run:

```
clab destroy -t ubuntu.clab.yml --cleanup
```

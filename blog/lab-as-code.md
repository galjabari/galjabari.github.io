---
layout: default
title: "Lab as Code with Containerlab"
---

# Lab as Code with Containerlab

Containerlab is a tool for deploying networking labs with Docker. It allows you to define your lab's topology in a YAML file and deploy it with a single command.

## 1. Install Containerlab on Linux

First, install Docker on your Linux machin by running:

```
curl -fsSL https://get.docker.com | sh
```

To install Containerlab on your Linux machine, run the following command:

```
curl -sL https://get.containerlab.dev | bash
```

Ensure your user has root (or sudo) privileges to execute Docker commands:

```
sudo usermod -aG docker $USER
```

Log out of your session and log back in so the changes take effect.

## 2. Create a network topology using Containerlab

To get started with Containerlab, let's create a network lab consisting of two Arista cEOS routers and two Linux clients. Each router in the lab connects to a separate client. The clients are manually configured with IP addresses and default gateways to enable network communication.

Create a file named `demo.clab.yml` and add the following content:

```yaml
name: demo
topology:
  nodes:
    # Router 1 (Arista cEOS)
    router1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: router1.cfg
    # Router 2 (Arista cEOS)
    router2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: router2.cfg
    # Client 1 (Linux container)
    client1:
      kind: linux
      image: alpine:latest  # Lightweight Linux image
      exec:
        - ip addr add 192.168.10.2/24 dev eth1
        - ip route replace default via 192.168.10.1
    # Client 2 (Linux container)
    client2:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.20.2/24 dev eth1
        - ip route replace default via 192.168.20.1
  links:
    # Link between router1 and router2
    - endpoints: ["router1:eth1", "router2:eth1"]
    # Link between router1 and client1
    - endpoints: ["router1:eth2", "client1:eth1"]
    # Link between router2 and client2
    - endpoints: ["router2:eth2", "client2:eth1"]
```

To automate router configuration during lab deployment, you can provide startup configuration files for the routers.

Create a file named `router1.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
ip routing
!
interface Ethernet1
  no switchport
  ip address 192.168.1.1/30
!
interface Ethernet2
  no switchport
  ip address 192.168.10.1/24
!
interface Loopback0
  ip address 10.10.10.1/32
!
router bgp 65001
  router-id 10.10.10.1
  neighbor 192.168.1.2 remote-as 65001
  network 192.168.10.0/24
!
end
```

Create a file named `router2.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
ip routing
!
interface Ethernet1
  no switchport
  ip address 192.168.1.2/30
!
interface Ethernet2
  no switchport
  ip address 192.168.20.1/24
!
interface Loopback0
  ip address 10.10.10.2/32
!
router bgp 65001
  router-id 10.10.10.2
  neighbor 192.168.1.1 remote-as 65001
  network 192.168.20.0/24
!
end
```

This lab uses BGP as the dynamic routing protocol, but you can also use OSPF as an alternative.

## 3. Deploy the network topology using Containerlab

To deploy the lab, run the following command in the same directory where you created the files:

```
containerlab deploy -t demo.clab.yml
```

![](../assets/clab.png)

After the lab is deployed, you can test the connectivity between the clients. Open a new terminal and connect to client1:

```
docker exec -it clab-demo-client1 sh
```

Ping client2 from client1:

```
ping 192.168.20.2
```

Connect to router1 CLI:

```
docker exec -it clab-demo-router1 Cli
```

Verify the routing table on router1:

```
show ip route
```

To generate a graph of the network topology, use the following command:

```
containerlab graph -t demo.clab.yml
```

This command creates an interactive HTML-based graph that you can access in a web browser.

## 4. Clean up the lab

After testing, you can clean up the lab environment. To destroy the lab, run:

```
containerlab destroy -t demo.clab.yml
```

This command removes all containers in the lab. To remove the lab and all related files, run:

```
containerlab destroy -t ceos.clab.yml --cleanup
```

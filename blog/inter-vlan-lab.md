---
title: "Configure Inter-VLAN Routing with a Router"
description: "Learn how to configure inter-VLAN routing using a router with Containerlab."
---

# Configure Inter-VLAN Routing with a Router

This guide demonstrates how to configure inter-VLAN routing using Containerlab with Arista cEOS. The lab consists of two VLANs, each with its own subnet, and a router that routes traffic between them.

## 1. Create a network topology

To create a network topology with two VLANs, you can use the following YAML configuration (`vlan.clab.yml`):

```
name: vlan
topology:
  nodes:
    router:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: router.cfg
    switch:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    client1:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.10.2/24 dev eth1
        - ip route replace default via 192.168.10.1
    client2:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.20.2/24 dev eth1
        - ip route replace default via 192.168.20.1
  links:
    - endpoints: ["switch:eth1", "client1:eth1"]
    - endpoints: ["switch:eth2", "client2:eth1"]
    - endpoints: ["switch:eth3", "router:eth1"]    
```

This configuration defines a router, a switch, and two clients, each connected to the switch. The router will handle inter-VLAN routing.

Next, create the configuration files for the switch and router.

In the same directory, create a file named `switch.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
hostname cEOS-Switch
!
vlan 10
   name VLAN10
vlan 20
   name VLAN20
!
interface Ethernet1
   switchport mode access
   switchport access vlan 10
!
interface Ethernet2
   switchport mode access
   switchport access vlan 20
!
interface Ethernet3
   switchport mode trunk
   switchport trunk allowed vlan 10,20
!
end          
```

This configuration sets up two access ports for VLAN 10 and VLAN 20, and a trunk port to connect to the router.

In the same directory, create a file named `router.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!          
hostname cEOS-Router
!
ip routing
!
interface Ethernet1
   no switchport
!
interface Ethernet1.10
   encapsulation dot1q vlan 10
   ip address 192.168.10.1/24
!
interface Ethernet1.20
   encapsulation dot1q vlan 20
   ip address 192.168.20.1/24
!
end          
```

This configuration enables inter-VLAN routing on the router by creating sub-interfaces for each VLAN, each with its own IP address.

## 2. Deploy the network topology

To deploy the network topology, run the following command:

```
containerlab deploy -t vlan.clab.yml
```

After the lab is deployed, you can test connectivity between the clients. Open a new terminal and connect to client1:

```
docker exec -it clab-vlan-client1 sh
```

Ping client2 from client1:

```
ping 192.168.20.2
```

To access the router CLI:

```
docker exec -it clab-vlan-router Cli
```

Verify the routing table on the router:

```
show ip route
```

## 3. Clean up the lab

After testing, you can clean up the lab environment. To remove the lab and all related files, run:

```
containerlab destroy -t vlan.clab.yml --cleanup
```

---
layout: default
title: "Configure VLAN Trunking on Arista cEOS"
---

# Configure VLAN Trunking on Arista cEOS

This guide demonstrates how to configure VLANs and VLAN trunking on Arista cEOS switches using Containerlab. The lab includes a Layer 3 switch providing routing and DHCP services, along with two Layer 2 switches that extend VLANs to connected client devices.

## 1. Create a network topology

To create a network topology, use the following Containerlab configuration file named `trunk.clab.yml`:

```
name: layer3
topology:
  nodes:
    # Layer 3 switch (Arista cEOS)
    spine:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: spine.cfg 
    # Layer 2 switch (Arista cEOS)
    leaf1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: leaf.cfg 
    # Layer 2 switch (Arista cEOS)
    leaf2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: leaf.cfg 
    # Client 1 (Linux container)
    client1:
      kind: linux
      image: alpine:latest
      # Use udhcpc for DHCP client functionality
      exec:
        - ip route del default
        - udhcpc -i eth1
    # Client 2 (Linux container)
    client2:
      kind: linux
      image: alpine:latest
      # Use udhcpc for DHCP client functionality
      exec:
        - ip route del default
        - udhcpc -i eth1
    # Client 3 (Linux container)
    client3:
      kind: linux
      image: alpine:latest 
      # Use udhcpc for DHCP client functionality
      exec:
        - ip route del default
        - udhcpc -i eth1
    # Client 4 (Linux container)
    client4:
      kind: linux
      image: alpine:latest
      # Use udhcpc for DHCP client functionality
      exec:
        - ip route del default
        - udhcpc -i eth1
  links:
    - endpoints: ["spine:eth1", "leaf1:eth3"]
    - endpoints: ["spine:eth2", "leaf2:eth3"]
    - endpoints: ["leaf1:eth1", "client1:eth1"]
    - endpoints: ["leaf1:eth2", "client2:eth1"]
    - endpoints: ["leaf2:eth1", "client3:eth1"]
    - endpoints: ["leaf2:eth2", "client4:eth1"]
```

This configuration defines the spine switch, two leaf switches, and four clients. Each client is set up to automatically obtain an IP address from the DHCP server running on the spine switch.

Next, create the startup configuration files for the switches.

In the same directory as your YAML file, create a file named `spine.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
ip routing
!
vlan 10
   name VLAN10
vlan 20
   name VLAN20
!
interface Vlan10
   ip address 192.168.10.1/24
   dhcp server ipv4
   no shutdown
!
interface Vlan20
   ip address 192.168.20.1/24
   dhcp server ipv4
   no shutdown
!
interface Ethernet1
   switchport mode trunk
   switchport trunk allowed vlan 10,20
!
interface Ethernet2
   switchport mode trunk
   switchport trunk allowed vlan 10,20
!
dhcp server
   subnet 192.168.10.0/24
      range 192.168.10.20 192.168.10.100
      default-gateway 192.168.10.1
   !
   subnet 192.168.20.0/24
      range 192.168.20.20 192.168.20.100
      default-gateway 192.168.20.1
   !
!
end
```

Create a file named `leaf.cfg`, which will be used for both leaf switches:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
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

## 2. Deploy and verify the lab

Deploy the topology with the following command:

```
clab deploy -t trunk.clab.yml
```

![](../assets/trunk.png)

After the lab is deployed, you can test connectivity between clients. For example, to test communication between clients in the same VLAN but on different switches, access `client1` and ping `client3`. You can access the client with the following command:

```
docker exec -it clab-trunk-client1 sh
```

To access the CLI for each switch, use the following commands:

```
docker exec -it clab-trunk-spine Cli
```

```
docker exec -it clab-trunk-leaf1 Cli
```

```
docker exec -it clab-trunk-leaf2 Cli
```

On the spine, verify the IP routing table and DHCP leases:

```
show ip route
```

```
show dhcp server leases
```

On the leaf switches, verify the VLAN and trunk interface configurations:

```
show vlan
```

```
show interfaces trunk
```

## 3. Clean up the lab

When you are finished, you can destroy the lab environment and remove all related files with the following command:

```
clab destroy -t trunk.clab.yml --cleanup
```

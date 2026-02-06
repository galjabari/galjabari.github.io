---
layout: default
title: "Configure Inter-VLAN Routing with a Layer 3 Switch"
---

# Configure Inter-VLAN Routing with a Layer 3 Switch

This guide demonstrates how to configure inter-VLAN routing using a Layer 3 switch on Containerlab. The lab consists of a Layer 3 switch that handles both routing and DHCP services for two separate VLANs.

## 1. Create a network topology

To create a network topology with two VLANs and a Layer 3 switch, you can use the following YAML configuration (`layer3.clab.yml`):

```yaml
name: layer3
topology:
  nodes:
    # Layer 3 switch (Arista cEOS)
    switch:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg 
    # Client 1 (Linux container)
    client1:
      kind: linux
      image: alpine:latest  # Lightweight Linux image
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
  links:
    # Link between switch and client 1
    - endpoints: ["switch:eth1", "client1:eth1"]
    # Link between switch and client 2
    - endpoints: ["switch:eth2", "client2:eth1"]
```

This configuration defines a Layer 3 switch and two clients. The clients will obtain their IP addresses from the DHCP server running on the switch.

Next, create the configuration file for the switch.

In the same directory, create a file named `switch.cfg` with the following content:

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
   switchport mode access
   switchport access vlan 10
!
interface Ethernet2
   switchport mode access
   switchport access vlan 20
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

This configuration enables IP routing, creates two VLANs with corresponding Layer 3 interfaces, and configures a DHCP server to assign IP addresses to clients in each VLAN.

## 2. Deploy the network topology

To deploy the network topology, run the following command:

```
clab deploy -t layer3.clab.yml
```

After the lab is deployed, you can test connectivity between the clients. Open a new terminal and connect to client1:

```
docker exec -it clab-layer3-client1 sh
```

Check the IP address assigned by the DHCP server:

```
ip addr show eth1
```

Do the same for client2 in another terminal:

```
docker exec -it clab-layer3-client2 sh
```

```
ip addr show eth1
```

Once you have the IP address of client2, ping it from client1 to test inter-VLAN routing.

To access the switch CLI:

```
docker exec -it clab-layer3-switch Cli
```

Verify the routing table on the switch:

```
show ip route
```

Verify DHCP server leases:

```
show dhcp server leases
```

## 3. Clean up the lab

After testing, you can clean up the lab environment. To remove the lab and all related files, run:

```
clab destroy -t layer3.clab.yml --cleanup
```

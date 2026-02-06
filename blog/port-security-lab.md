---
layout: default
title: "Configure Port Security on Arista cEOS"
---

# Configure Port Security on Arista cEOS

Port security is a network security feature that restricts the devices that can connect to a switch port. It helps prevent unauthorized access and attacks by limiting the number of MAC addresses that can be learned on a port and by taking action when a violation occurs.

This guide demonstrates how to configure port security on Arista cEOS switches using Containerlab.

## 1. Create a network topology

To create a network topology, use the following Containerlab configuration file named `portsec.clab.yml`:

```
name: portsec
topology:
  nodes:
    switch1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch1.cfg
    switch2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch2.cfg
    client1:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.10.101/24 dev eth1      
    client2:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.10.102/24 dev eth1
    attacker:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.10.103/24 dev eth1
  links:
    - endpoints: ["switch1:eth1", "switch2:eth1"]
    - endpoints: ["switch1:eth2", "client1:eth1"]
    - endpoints: ["switch2:eth2", "client2:eth1"]
    - endpoints: ["switch1:eth3", "attacker:eth1"]
```

This topology defines two switches and three clients, one of which is an attacker attempting to connect to the network.

Next, create the startup configuration files for the switches.

In the same directory as your YAML file, create a file named `switch1.cfg` with the following content:

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
interface Ethernet3
   switchport
!
end
```

Create a file named `switch2.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
interface Ethernet1
   switchport
   switchport mode access
   switchport port-security
   switchport port-security maximum 1
   switchport port-security violation shutdown
   switchport port-security mac-address sticky
!
interface Ethernet2
   switchport
!
end
```

This configuration enables port security on `switch2`, allowing only one MAC address on `Ethernet1`. If a second MAC address is detected, the port will be shut down.

## 2. Deploy and verify the lab

Deploy the topology with the following command:

```
clab deploy -t portsec.clab.yml
```

After the lab is deployed, you can test the port security configuration. Access `client1` and try to ping `client2`. Then, access the `attacker` and try to ping `client2`. The ping from the attacker should fail, and the port on `switch2` should be shut down.

To access `client1`, use the following command:

```
docker exec -it clab-portsec-client1 sh
```

On `client1`, you can ping `client2`:

```
ping 192.168.10.102
```

To access `attacker`, use the following command:

```
docker exec -it clab-portsec-attacker sh
```

On the attacker, you can try to ping `client2`:

```
ping 192.168.10.102
```

Now, access `switch2` to verify the port status:

```
docker exec -it clab-portsec-switch2 Cli
```

You can verify the port security status with the following command:

```
show port-security
```

## 3. Clean up the lab

When you are finished, you can destroy the lab environment and remove all related files with the following command:

```
clab destroy -t portsec.clab.yml --cleanup
```

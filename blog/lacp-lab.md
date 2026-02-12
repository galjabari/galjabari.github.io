---
layout: default
title: "Configure Port Channel on Arista cEOS"
---

# Configure Port Channel on Arista cEOS

Link Aggregation Control Protocol (LACP) is a standardized protocol that allows multiple physical Ethernet links to be combined into a single logical link—called a Port Channel or EtherChannel—to increase bandwidth and provide redundancy.

This guide demonstrates how to configure a Port Channel on Arista cEOS switches using Containerlab.

## 1. Create a network topology

To create a network topology, use the following Containerlab configuration file named `lacp.clab.yml`:

```yaml
name: lacp
topology:
  nodes:
    switch1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    switch2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
  links:
    - endpoints: ["switch1:eth1", "switch2:eth1"]
    - endpoints: ["switch1:eth2", "switch2:eth2"]
```

This topology defines two switches with two redundant links that will be bundled into a Port Channel.

Next, create the startup configuration files for the switches.

In the same directory as your YAML file, create a file named `switch.cfg`, which will be used for both switches:

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
   channel-group 1 mode active
!
interface Ethernet2
   channel-group 1 mode active
!
interface Port-Channel1
   switchport mode trunk
   switchport trunk allowed vlan 10,20
!
end
```

This configuration file sets up two VLANs (10 and 20) and configures Ethernet1 and Ethernet2 to be part of Port Channel 1 in active LACP mode. The Port Channel interface is set to trunk mode, allowing VLANs 10 and 20.

## 2. Deploy and verify the lab

Deploy the topology with the following command:

```bash
clab deploy -t lacp.clab.yml
```

After the lab is deployed, you can verify the LACP configuration. Access `switch1` and check the Port Channel status.

To access `switch1`, use the following command:

```bash
docker exec -it clab-lacp-switch1 Cli
```

On `switch1`, you can check the Port Channel status with the following command:

```
show port-channel
```

You should see output indicating that Port Channel 1 is up and includes both Ethernet1 and Ethernet2 as members.

To verify Port Channel interface details, you can use:

```
show interfaces Port-Channel1
```

## 3. Clean up the lab

When you are finished, you can destroy the lab environment and remove all related files with the following command:

```bash
clab destroy -t lacp.clab.yml --cleanup
```

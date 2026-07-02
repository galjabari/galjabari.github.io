---
layout: default
title: "Software-Defined Networking in Proxmox VE"
categories: ["Proxmox VE Administration", "Software-Defined Networking"]
tags: ["Proxmox VE", "SDN", "Networking", "CLI"]
---

# Software-Defined Networking in Proxmox VE

This lab introduces Software-Defined Networking (SDN) concepts within Proxmox VE, demonstrating how to install necessary components, create SDN zones, virtual networks (VNets), subnets, and integrate them with virtual machines and containers.

## 1. Install DHCP and IPAM (dnsmasq)

Proxmox VE can leverage `dnsmasq` for DHCP services within its SDN setup. First, install `dnsmasq` and then disable its default system instance, as Proxmox VE will manage it.

### Install DHCP and IPAM
```bash
apt update
apt install dnsmasq
# Disable default instance
systemctl disable --now dnsmasq
```

## 2. Configure SDN Zones and Virtual Networks

SDN in Proxmox VE is built around zones and virtual networks. Zones define the underlying network technology, while VNets create isolated network segments.

### Create zone
Create an SDN zone, specifying its type (e.g., `simple`, `vlan`, `qinq`, `vxlan`, `evpn`) and a unique zone ID. This command is the first step in defining your software-defined network.
```bash
pvesh create /cluster/sdn/zones --type <type> --zone <zone-id>
```

### Create virtual network (VNet)
A virtual network (`VNet`) operates within an SDN zone and provides a logical network segment for your VMs and containers. You need to specify a VNet ID and associate it with a previously created zone.
```bash
pvesh create /cluster/sdn/vnets --vnet <vnet-id> --zone <zone-id>
```

### Create subnet (CIDR)
Within a VNet, you can define one or more subnets using CIDR notation. This command creates a subnet and can include options for a gateway and DHCP range.
```bash
pvesh create /cluster/sdn/vnets/<vnet-id>/subnets --subnet <cidr> --type subnet
```

### Apply changes
After making changes to the SDN configuration, you must apply them for the changes to take effect across the cluster.
```bash
pvesh set /cluster/sdn
```

### Simple Zone
This example demonstrates how to create a `simple` zone with NAT, a VNet, and a subnet with DHCP capabilities. It also shows how to remove this configuration.

```bash
# Create simple zone with NAT
pvesh create /cluster/sdn/zones --type simple --zone internal --dhcp dnsmasq --ipam pve
pvesh create /cluster/sdn/vnets --vnet vnet1 --zone internal
pvesh create /cluster/sdn/vnets/vnet1/subnets --subnet 10.0.1.0/24 --type subnet --gateway 10.0.1.1 --snat 1 --dhcp-range "start-address=10.0.1.2,end-address=10.0.1.100"
pvesh set /cluster/sdn

# Remove simple zone
pvesh delete /cluster/sdn/vnets/vnet1/subnets/internal-10.0.1.0-24
pvesh delete /cluster/sdn/vnets/vnet1
pvesh delete /cluster/sdn/zones/internal
pvesh set /cluster/sdn
```

## 3. Attach Virtual Machines and Containers to VNets

Once your SDN is configured, you can connect your VMs and containers to the defined virtual networks.

### Attach VM to VNet
Modify the network configuration of a virtual machine to connect it to a specific VNet. Replace `<vmid>` with the VM's ID and `<vnet-id>` with the VNet's ID.
```bash
qm set <vmid> --net0 virtio,bridge=<vnet-id>
```

### Attach Container to VNet
Similarly, attach a Linux Container to a VNet. This command configures the container's `eth0` interface to use the VNet bridge and obtain an IP address via DHCP.
```bash
pct set <vmid> --net0 name=eth0,bridge=<vnet-id>,ip=dhcp
```
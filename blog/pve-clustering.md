---
layout: default
title: "Proxmox VE Clustering"
categories: ["Proxmox VE Administration", "Clustering"]
tags: ["Proxmox VE", "Cluster", "High Availability", "CLI"]
---

# Proxmox VE Clustering

This lab provides a guide to setting up and managing a Proxmox VE cluster, enabling features like live migration and high availability. You'll learn how to create a cluster, add nodes, and perform basic VM/container migrations.

## 1. Create and Manage a Proxmox VE Cluster

Clustering multiple Proxmox VE nodes allows for centralized management, live migration of VMs, and high availability.

### Create Cluster
On your first Proxmox VE node, create a new cluster using the `pvecm create` command. Choose a meaningful `<cluster-name>`.
```bash
pvecm create <cluster-name>
```

### Check status
After creating or joining a cluster, always check its status to ensure all nodes are communicating correctly and the cluster is healthy.
```bash
pvecm status
```

### Join nodes to Cluster
On additional Proxmox VE nodes, use the `pvecm add` command to join them to the existing cluster. Replace `<cluster-ip-address>` with the IP address of an existing node in the cluster.
```bash
pvecm add <cluster-ip-address>
```

### List all nodes
To get a list of all nodes currently participating in the cluster, use `pvecm nodes`.
```bash
pvecm nodes
```

### Example
Here's a typical workflow for setting up a two-node cluster:

```bash
# On the first node
pvecm create pve-cluster
pvecm status
# On additional nodes
pvecm add 192.168.10.11
pvecm nodes
```

## 2. Migrate Virtual Machines and Containers

Live migration (for VMs) and restarting migration (for containers) allow you to move workloads between cluster nodes without downtime (live migration) or with minimal interruption.

### Migrate VM
To perform a live migration of a virtual machine, use `qm migrate`. The `--online` flag enables live migration, which moves the VM without stopping it.
```bash
qm migrate <vmid> <target-node> --online
```

### Migrate container
Linux Containers can also be migrated between nodes. The `--restart` flag indicates that the container will be stopped on the source node and restarted on the target node.
```bash
pct migrate <vmid> <target-node> --restart
```

## 3. VXLAN Zone

For seamless migration of VMs and containers, especially when moving between different physical networks or for more complex network topologies, SDN (Software-Defined Networking) with technologies like VXLAN can be utilized.

This example configures a VXLAN zone, a virtual network, and a subnet, allowing for network abstraction and facilitating migration across different underlying physical networks. It also shows how to clean up the VXLAN configuration.

```bash
# Create VXLAN zone
pvesh create /cluster/sdn/zones --zone vxlan --type vxlan --peers 192.168.10.11,192.168.10.12 --mtu 1450
pvesh create /cluster/sdn/vnets --vnet vnet100 --zone vxlan --tag 100
pvesh create /cluster/sdn/vnets/vnet100/subnets --subnet 10.0.100.0/24 --type subnet --gateway 10.0.100.1 --snat 1
pvesh set /cluster/sdn

# Remove VXLAN zone
pvesh delete /cluster/sdn/vnets/vnet100/subnets/vxlan-10.0.100.0-24
pvesh delete /cluster/sdn/vnets/vnet100
pvesh delete /cluster/sdn/zones/vxlan
pvesh set /cluster/sdn
```
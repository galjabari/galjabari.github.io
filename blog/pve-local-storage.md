---
layout: default
title: "Local Storage in Proxmox VE"
categories: ["Proxmox VE Administration", "Local Storage"]
tags: ["Proxmox VE", "Storage", "ZFS", "CLI"]
---

# Local Storage in Proxmox VE

This lab provides a guide to managing local storage within Proxmox VE, focusing on how to list existing storage, add new storage pools, and specifically how to set up and manage ZFS storage.

## 1. Proxmox Storage

Proxmox VE allows you to manage various types of storage for your virtual machines and containers.

### List storage pools
This command displays a summary of all configured storage pools in Proxmox VE, including their type, content, and available space.
```bash
pvesm status
```

### List storage contents
To view the contents of a specific storage pool (e.g., ISO images, VM disks, container templates), use `pvesm list` followed by the storage ID.
```bash
pvesm list <storage-id>
```

### Add storage pools
This command allows you to add a new storage pool to Proxmox VE. You need to specify the storage type (e.g., `zfspool`, `dir`, `nfs`, `lvm`, `iscsi`) and a unique ID for the new storage.
```bash
pvesm add <type> <storage-id>
```

## 2. ZFS Storage

ZFS is a powerful file system and logical volume manager often used in Proxmox VE for its data integrity features, snapshots, and performance.

This comprehensive example walks through creating a ZFS RAID 1 pool, enabling compression, adding it as storage to Proxmox VE, and then demonstrating how to remove it.

### List available devices
First, identify the unpartitioned disks that you want to use for your ZFS pool. The `lsblk -d` command lists block devices without showing partitions.
```bash
lsblk -d
```
### Create local ZFS pool (RAID 1)
Create a new ZFS pool named `local-zfs` using two disks in a mirror (RAID 1) configuration. Replace `/dev/sdb` and `/dev/sdc` with your actual disk identifiers.
```bash
zpool create local-zfs mirror /dev/sdb /dev/sdc
```
### Enable lz4 compression
Enable `lz4` compression for the ZFS pool. This can save disk space and improve I/O performance.
```bash
zfs set compression=lz4 local-zfs
```
### Check ZFS pool status
Verify the status of your newly created ZFS pool, ensuring it's healthy.
```bash
zpool status
```
### List ZFS pools
List all active ZFS pools on your system.
```bash
zpool list
```
### List available ZFS pools
Scan for ZFS pools that Proxmox VE can recognize and add as storage.
```bash
pvesm scan zfs
```
### Add ZFS storage to Proxmox
Add the ZFS pool to Proxmox VE as a storage backend. The `-content images,rootdir` specifies that it can store disk images and container root directories. `-sparse 1` enables thin provisioning.
```bash
pvesm add zfspool vmdata -pool local-zfs -content images,rootdir -sparse 1
```
### Remove ZFS storage
If you need to remove the ZFS storage from Proxmox VE, use `pvesm remove`.
```bash
pvesm remove vmdata
```
### Remove local ZFS pool
To completely destroy the ZFS pool and release the disks, use `zpool destroy`.
```bash
zpool destroy local-zfs
```
### Remove ZFS and partition signatures
After destroying the ZFS pool, it's a good idea to wipe the disk signatures to ensure they are clean for future use.
```bash
wipefs -a /dev/sdb /dev/sdc
```
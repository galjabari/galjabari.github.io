---
layout: default
title: "Virtual Machine Management in Proxmox VE"
categories: ["Proxmox VE Administration", "Virtual Machine Management"]
tags: ["Proxmox VE", "VM", "Virtualization", "CLI"]
---

# Virtual Machine Management in Proxmox VE

This lab provides a comprehensive guide to managing virtual machines (VMs) in Proxmox VE using the command-line interface. You will learn how to list, create, configure, and control the lifecycle of your VMs.

## 1. Download ISO Images

Before creating VMs, you often need to download and manage ISO images for installation.

### List all VMs
This command provides a quick overview of all virtual machines configured on your Proxmox VE host, including their IDs, names, status, and associated node.
```bash
qm list
```

### Download ISO
Navigate to the ISO storage directory and download the desired ISO image using `wget`. Replace `<URL>` with the direct download link for your ISO.
```bash
cd /var/lib/vz/template/iso
wget <URL>
```

### List ISO images
This command lists all ISO images available in your local storage, which can be used for VM installations.
```bash
pvesm list local --content iso
```

## 2. Create a Virtual Machine

Creating a VM involves several steps, from defining its basic parameters to attaching storage and boot media. The `qm create` command initializes a new VM, and `qm set` is used for further configuration.

- `qm create <vmid> --name <name> --memory <MiB> --cores <n> --net0 virtio,bridge=vmbr0`: Creates a new VM with a specified ID, name, memory, CPU cores, and a network interface connected to `vmbr0` using the `virtio` driver.
- `qm set <vmid> --scsihw virtio-scsi-pci --scsi0 local-lvm:<GiB>`: Configures a SCSI hard disk using the `virtio-scsi-pci` controller, allocating a certain amount of GB from the `local-lvm` storage.
- `qm set <vmid> --ide2 local:iso/<filename>,media=cdrom`: Attaches an ISO image as a CD-ROM drive for installation.
- `qm set <vmid> --boot "order=scsi0;ide2"`: Sets the boot order, prioritizing the SCSI hard disk and then the CD-ROM.

Here's a complete example of creating an Alpine Linux VM:
```bash
cd /var/lib/vz/template/iso
wget https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-virt-3.23.3-x86_64.iso
qm create 100 --name alpine --memory 512 --cores 2 --net0 virtio,bridge=vmbr0 
qm set 100 --scsihw virtio-scsi-pci --scsi0 local-lvm:2
qm set 100 --ide2 local:iso/alpine-virt-3.23.3-x86_64.iso,media=cdrom
qm set 100 --boot "order=scsi0;ide2"
```

## 3. View VM Information

### Show VM configuration
To review the detailed configuration of a specific VM, use the `qm config` command.
```bash
qm config <vmid>
```

### Show VM status
Check the current power state and other runtime information of a VM.
```bash
qm status <vmid>
```

## 4. Control VM Power State

### Start VM
Initiate the startup process for a virtual machine.
```bash
qm start <vmid>
```

### Enable start at boot
Configure a VM to automatically start when the Proxmox VE host boots up.
```bash
qm set <vmid> --onboot 1
```

### Shutdown VM
Gracefully shut down a running virtual machine. This sends an ACPI shutdown signal to the guest OS.
```bash
qm shutdown <vmid>
```

### Stop VM 
Forcefully stops a virtual machine. Use this if a graceful shutdown is not possible or the VM is unresponsive.
```bash
qm stop <vmid> 
```

### Restart VM
Reboots a running virtual machine.
```bash
qm reboot <vmid>
```

## 5. QEMU Guest Agent

The QEMU guest agent enhances communication between the Proxmox host and the guest VM, allowing for more advanced operations like proper shutdown, file system freeze for backups, and guest IP address reporting.

### Enable QEMU guest agent
Enable the QEMU guest agent in the VM's configuration. You also need to install the agent within the guest operating system.
```bash
qm set <vmid> --agent enabled=1
```

### Check QEMU guest agent
After enabling and installing the guest agent, you can query information from the guest OS, such as operating system details and network interfaces.
```bash
qm guest cmd <vmid> get-osinfo
qm guest cmd <vmid> network-get-interfaces
```

## 6. VM Templates and Cloning

Templates are pre-configured VMs that can be quickly cloned to create new instances.

### Convert VM to template
Convert an existing VM into a template. Templates cannot be started directly but serve as a master image for cloning.
```bash
qm template <vmid>
```

### Clone VM

- **Linked clone**: Creates a new VM that shares the base disk image with the source template. This saves disk space but depends on the original template.
- **Full clone**: Creates an independent copy of the VM, including all disk images. This requires more disk space but is self-contained.

```bash
# Linked clone
qm clone <source-vmid> <new-vmid> --name <new-name>
# Full clone
qm clone <source-vmid> <new-vmid> --name <new-name> --full
```

## 7. Remove VM

To permanently delete a virtual machine, including all its associated disks, use `qm destroy`. The `--purge` flag ensures all configuration files and disks are removed.
```bash
qm destroy <vmid> --purge
```
---
layout: default
title: "Linux Container Management in Proxmox VE"
categories: ["Proxmox VE Administration", "Linux Container Management"]
tags: ["Proxmox VE", "LXC", "Containers", "CLI"]
---

# Linux Container Management in Proxmox VE

This lab focuses on managing Linux Containers (LXC) within Proxmox VE using the command-line interface. You'll learn how to list, download, create, configure, and control containers.

## 1. Download Container Templates

Container templates are base images used to quickly deploy new LXC containers.

### List all containers
This command displays a list of all Linux Containers on your Proxmox VE host, including their IDs, names, status, and associated node.
```bash
pct list
```

### List all available templates
To see all container templates that are available for download from the Proxmox VE repositories, use this command.
```bash
pveam available
```

### List available system templates
If you want to filter the available templates to only see system-level templates (e.g., Ubuntu, Debian, CentOS), use the `--section system` flag.
```bash
pveam available --section system
```

### Download template
Download a specific container template to your local Proxmox VE storage. Replace `<filename>` with the desired template name (e.g., `ubuntu-24.04-standard_24.04-2_amd64.tar.zst`).
```bash
pveam download local <filename>
```

### List downloaded templates
Verify that the template has been successfully downloaded and is available in your local storage.
```bash
pvesm list local --content vztmpl
```

### Remove template
To free up storage space, you can remove downloaded templates that are no longer needed. Replace `<filename>` with the full template path.
```bash
pveam remove local:vztmpl/<filename>
```

## 2. Create a Linux Container

### Create container
Creating an LXC container involves specifying a VMID, the template to use, root file system size, and a password. The `pct create` command initializes the container, and `pct set` is used for additional configuration.

- `pct create <vmid> local:vztmpl/<filename> --rootfs local-lvm:<GiB> --password <password>`: Creates a new container with a specified ID, using a local template, allocating root file system storage from `local-lvm`, and setting a root password.
- `pct set <vmid> --hostname <name> --memory <MiB> --cores <n> --net0 name=eth0,bridge=vmbr0,ip=dhcp`: Configures the container's hostname, memory, CPU cores, and a network interface (`eth0`) connected to `vmbr0` with DHCP.

Here's a complete example of downloading an Ubuntu 24.04 template and creating a new container:
```bash
pveam download local ubuntu-24.04-standard_24.04-2_amd64.tar.zst
pct create 200 local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst --rootfs local-lvm:8 --password ubuntu
pct set 200 --hostname ubuntu --memory 512 --cores 2 --net0 name=eth0,bridge=vmbr0,ip=dhcp 
```

## 3. View Container Information

### Show configuration
To review the detailed configuration of a specific container, use the `pct config` command.
```bash
pct config <vmid>
```

### Show status
Check the current power state and other runtime information of a container.
```bash
pct status <vmid>
```

## 4. Control Container Power State

### Start container
Initiate the startup process for a Linux Container.
```bash
pct start <vmid>
```

### Enable start at boot
Configure a container to automatically start when the Proxmox VE host boots up.
```bash
pct set <vmid> --onboot 1
```

### Shutdown container
Gracefully shut down a running container. This sends a signal to the guest OS to perform a controlled shutdown.
```bash
pct shutdown <vmid>
```

### Stop container
Forcefully stops a container. Use this if a graceful shutdown is not possible or the container is unresponsive.
```bash
pct stop <vmid>
```

### Restart container
Reboots a running container.
```bash
pct restart <vmid>
```

## 5. Access Container Console and Shell

### Console access (login)
Access the container's console for direct interaction. You can log in using the credentials configured during creation. To exit, press `Ctrl+a` followed by `q`.
```bash
pct console <vmid>
```

### Enter shell
Directly enter the shell of a running container without needing to log in.
```bash
pct enter <vmid>
```

## 6. Container Templates and Cloning

Templates are pre-configured containers that can be quickly cloned to create new instances.

### Convert container to template
Convert an existing container into a template. Templates cannot be started directly but serve as a master image for cloning.
```bash
pct template <vmid>
```

### Clone container

- **Linked clone**: Creates a new container that shares the base disk image with the source template. This saves disk space but depends on the original template.
- **Full clone**: Creates an independent copy of the container, including all disk images. This requires more disk space but is self-contained.

```bash
# Linked clone
pct clone <source-vmid> <new-vmid>
# Full clone
pct clone <source-vmid> <new-vmid> --full
```

## 7. Remove Container

To permanently delete a Linux Container, including all its associated disks, use `pct destroy`. The `--purge` flag ensures all configuration files and disks are removed.
```bash
pct destroy <vmid> --purge
```
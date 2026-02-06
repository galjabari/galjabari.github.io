---
title: "Infrastructure as Code with Terraform"
---

# Infrastructure as Code with Terraform

To automate and manage resources in Proxmox or on any cloud provider, you can use Terraform for infrastructure as code.

First, set up Proxmox VE and configure API access with appropriate user permission for Terraform to interact with Proxmox:

- Log in to the Proxmox web interface. Navigate to `Datacenter -> Permissions -> Users` and click on Add to create a new user (e.g. `terraform`).
- Next, you need to generate an API token. Navigate to `Datacenter -> Permissions -> API Tokens` and click on Add to create a token for the user.
- Provide a name for the token (e.g. `terraform-token`) and ensure "Privilege Separation" is disabled, then click Add to generate it. Copy the generated API token for use with Terraform.
- Navigate to `Datacenter -> Permissions`, then click Add to create a permission for the user. Select "/" for the path and "Administrator" for the role.

## Install Terraform on Ubuntu

To install Terraform on your Linux machine, run the following commands:

```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

Verify the installation by checking the Terraform version:

```
terraform --version
```

## Configure Proxmox provider

To define the Proxmox provider and API access in Terraform, you need to create a `main.tf` configuration file:

```
nano main.tf
```

Add the following content:

```
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}
provider "proxmox" {
  pm_api_url = "https://192.168.1.10:8006/api2/json"
  pm_api_token_id = "terraform@pam!terraform-token"
  pm_api_token_secret = "e653d906-575a-497d-8bfe-6bad7a9ddfac"
  pm_tls_insecure = true
}
```

Replace `192.168.1.10` with the IP address or hostname of your Proxmox server. Paste the API token you have generated into `pm_api_token_secret`.

Run the following command to install the Proxmox provider:

```
terraform init
```

## Deploy an LXC in Proxmox

Terraform can be used with Proxmox to automate the deployment of virtual machines (VMs) and Linux containers (LXC).

To define and manage LXC containers using Terraform, create a Terraform configuration file:

```
nano lxc.tf
```

Add the following content:

```
resource "proxmox_lxc" "ubuntu-ct" {
  target_node     = "pve"
  hostname        = "ubuntu-ct"
  ostemplate      = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  password        = "ubuntu"
  unprivileged    = true
  cores           = 2
  memory          = 1024
  start           = true # start after creation
  ssh_public_keys = file("~/.ssh/id_rsa.pub")
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
}
```

Make sure to download the specified container image or template on Proxmox before using it in Terraform. You can generate SSH keys on your machine to login to remote hosts using the `ssh-keygen` command.

Run the following command to view the planned changes:

```
terraform plan
```

Run the following command to apply the changes:

```
terraform apply -auto-approve
```

This will create the LXC container based on the template. When you're done, use `terraform destroy` to delete the container.

## Deploy a VM in Proxmox

To deploy a virtual machine (VM) in Proxmox with Terraform, you need to create a Terraform configuration to clone a VM from a template.

You can create a VM template from a cloud image in Proxmox by executing the following commands:

```
# install the necessary tools to manage disk images
apt update && apt install libguestfs-tools -y
# download Ubuntu 22.04 cloud image
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
# modify the cloud disk image to install QEMU guest agent
virt-customize -a jammy-server-cloudimg-amd64.img --install qemu-guest-agent --run-command 'systemctl enable qemu-guest-agent'
# create a new VM with VirtIO SCSI controller
qm create 9000 --name ubuntu-22.04-template --cores 2 --memory 1024 --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci
# import the disk image to local-lvm storage
qm disk import 9000 jammy-server-cloudimg-amd64.img local-lvm
# attach the imported disk as a SCSI drive
qm set 9000 --scsi0 local-lvm:vm-9000-disk-0
# increase the size of the SCSI disk to 5GB
qm disk resize 9000 scsi0 5G
# configure a CD-ROM drive with cloud-init data
qm set 9000 --ide2 local-lvm:cloudinit
# configure the boot order to boot from the SCSI disk
qm set 9000 --boot order=scsi0
# configure a serial console and use it as a display
qm set 9000 --serial0 socket --vga serial0
# configure network settings
qm set 9000 --ipconfig0 ip=dhcp
# set a password for the default user account (ubuntu)
qm set 9000 --cipassword ubuntu
# enable QEMU guest agent
qm set 9000 --agent enabled=1
# convert the VM into a template
qm template 9000
```

In Terraform, create a configuration file:

```
nano vm.tf
```

Add the following content:

```
resource "proxmox_vm_qemu" "ubuntu-vm" {
  name        = "ubuntu-vm"
  target_node = "pve"
  clone       = "ubuntu-22.04-template"
  agent       = 1 # enable QEMU guest agent
  cores       = 2
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  boot        = "order=scsi0"
  sshkeys     = file("~/.ssh/id_rsa.pub")
  ipconfig0   = "ip=dhcp"
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "20G"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }
  network {
    bridge    = "vmbr0"
    model     = "virtio"
  }
}
```

Run `terraform plan` to preview the changes. After reviewing the plan, run `terraform apply` to create the VM based on the cloud image template.

---
title: "Create Docker Swarm using Terraform and Ansible"
---

# Create Docker Swarm using Terraform and Ansible

To create a Docker Swarm cluster on Proxmox, you can use Terraform to provision the infrastructure and Ansible to configure and manage the Docker hosts.

First, you need to install [Ansible](linux-automation.md) and [Terraform](infrastructure-as-code.md) on your Linux machine. Next, set up Proxmox VE and create an API token for Terraform access.

To automate the deployment of a Docker Swarm cluster, you need to clone my repository to your machine:

```
git clone https://github.com/galjabari/cloud-computing.git
```

Run Terraform to provision the infrastructure:

```
cd cloud-computing/swarm
terraform init
terraform apply -auto-approve
```

This will create a Swarm cluster with one manager node and two worker nodes. Replace the IP addresses of the Swarm nodes with the IP addresses for your network.

Run Ansible playbook to configure the Docker Swarm cluster:

```
ansible-playbook -i hosts.ini create_swarm.yml
```

The playbook includes tasks to install Docker on the nodes, initialize the Swarm on the manager node, and join the worker nodes to the Swarm.

Run Ansible playbook to deploy a service and verify the cluster:

```
ansible-playbook -i hosts.ini deploy_nginx.yml
```

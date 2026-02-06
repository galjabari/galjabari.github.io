---
layout: default
title: "Linux Automation with Ansible and Containerlab"
---

# Linux Automation with Ansible and Containerlab

This guide demonstrates how to automate the configuration of Linux servers using Ansible in a Containerlab environment. We will use the same lab topology as in the [Build custom Ubuntu node for Containerlab](build-ubuntu-clab.md) guide to install and configure a web server on Ubuntu.

First, create the lab topology file named `ubuntu.clab.yml`:

```yaml
name: ubuntu
topology:
  nodes:
    switch:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    client:
      kind: linux
      image: clab-ubuntu:latest
      exec:
        - ip addr add 192.168.10.2/24 dev eth1
    server:
      kind: linux
      image: clab-ubuntu:latest
      exec:
        - ip addr add 192.168.10.3/24 dev eth1
  links:
    - endpoints: ["switch:eth1", "client:eth1"]
    - endpoints: ["switch:eth2", "server:eth1"]
```

Make sure to build the Ubuntu node image before deploying the lab.

Create the switch configuration file named `switch.cfg`:

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
end
```

Create an Ansible playbook named `nginx.yml` to install and configure Nginx on the server:

```yaml
---
- name: Install Nginx on Ubuntu server
  hosts: clab-ubuntu-server
  vars:
    ansible_user: clab
    ansible_password: clab
    ansible_become_password: clab
    ansible_host_key_checking: false
  gather_facts: false
  become: yes 
  tasks:
    - name: Update repositories cache and install Nginx
      ansible.builtin.apt:
        name: nginx
        state: latest
        update_cache: yes
    - name: Start and enable Nginx service
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: yes
```

Deploy the lab:

```
clab deploy -t ubuntu.clab.yml
```

Run the Ansible playbook:

```
ansible-playbook -i clab-ubuntu/ansible-inventory.yml nginx.yml
```

After the playbook execution, verify the Nginx installation by connecting to the client and accessing the server's web page:

```
ssh clab@clab-ubuntu-client
```

From the client, use `curl` to check the Nginx default page:

```
curl http://192.168.10.3
```

To destroy the lab, run:

```
clab destroy -t ubuntu.clab.yml --cleanup
```

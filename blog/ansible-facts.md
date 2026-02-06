---
title: "Get system information with Ansible facts"
---

# Get system information with Ansible facts

This guide assumes you have already installed [Ansible on your control node](linux-automation.md) and you need to gather facts or variables containing information about your remote hosts using Ansible.

To view system information for a target host with Ansible, you need to create an inventory file listing target hosts:

```
nano hosts.ini
```

For example, add the following lines to define your servers:

```
[servers]
server1 ansible_host=192.168.1.101
server2 ansible_host=192.168.1.102

[servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_host_key_checking=false
```

Ensure that the SSH service is installed and properly configured on the target hosts for connecting with SSH keys.

Create a playbook to gather facts about your target hosts. For example:

```
nano system_info.yml
```

Add the following lines into the playbook:

```yaml
---
- name: Gather facts and print system information
  hosts: all
  gather_facts: yes
  tasks:
    - name: Print system information
      ansible.builtin.debug:
        msg: |
          Hostname: {{ ansible_facts['hostname'] }}
          OS: {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}
          Kernel: {{ ansible_facts['kernel'] }}
          Architecture: {{ ansible_facts['architecture'] }}
          CPU: {{ ansible_facts['processor'][2] }}
          CPU Cores: {{ ansible_facts['processor_cores'] }}
          Memory: {{ (ansible_facts['memtotal_mb'] / 1024) | round(2) }}GB
    - name: Print disk usage
      ansible.builtin.debug:
        msg: |
          Size: {{ (ansible_facts['mounts'][0]['size_total']  / (1024*1024*1024)) | round(1) }}GB
          Used: {{ ((ansible_facts['mounts'][0]['size_total'] - ansible_facts['mounts'][0]['size_available'])  / (1024*1024*1024)) | round(1) }}GB
          Free: {{ (ansible_facts['mounts'][0]['size_available']  / (1024*1024*1024)) | round(1) }}GB
          Used(%): {{ ((ansible_facts['mounts'][0]['size_total'] - ansible_facts['mounts'][0]['size_available']) / ansible_facts['mounts'][0]['size_total']  * 100) | round(1) }}%
    - name: Print IPv4 settings
      ansible.builtin.debug:
        msg: |
          IP Address: {{ ansible_facts['default_ipv4']['address'] }}
          MAC Address: {{ ansible_facts['default_ipv4']['macaddress'] }}
          Default Gateway: {{ ansible_facts['default_ipv4']['gateway'] }}
```

Run the playbook:

```
ansible-playbook -i hosts.ini system_info.yml
```

This will display some useful system facts including OS, CPU, Memory, Disk, and IPv4 addresses.

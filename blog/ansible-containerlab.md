---
layout: default
title: "Network Automation with Ansible and Containerlab"
---

# Network Automation with Ansible and Containerlab
This guide walks through automating network device configuration using Ansible and Containerlab. We will use the same lab topology as in the [Lab as Code with Containerlab](lab-as-code.md) guide, but this time, we'll use Ansible to configure the Arista cEOS routers.
First, ensure you have Containerlab and Ansible installed on your Linux system. You can verify the installations by running:
```
containerlab version
ansible --version
```
## 1. Create the lab topology with Containerlab
The lab consists of two Arista cEOS routers and two Linux clients. Create a file named `demo.clab.yml` and add the following configuration:
```yaml
name: demo
topology:
  nodes:
    # Router 1 (Arista cEOS)
    router1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
    # Router 2 (Arista cEOS)
    router2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
    # Client 1 (Linux container)
    client1:
      kind: linux
      image: alpine:latest  # Lightweight Linux image
      exec:
        - ip addr add 192.168.10.2/24 dev eth1
        - ip route replace default via 192.168.10.1
    # Client 2 (Linux container)
    client2:
      kind: linux
      image: alpine:latest
      exec:
        - ip addr add 192.168.20.2/24 dev eth1
        - ip route replace default via 192.168.20.1
  links:
    # Link between router1 and router2
    - endpoints: ["router1:eth1", "router2:eth1"]
    # Link between router1 and client1
    - endpoints: ["router1:eth2", "client1:eth1"]
    # Link between router2 and client2
    - endpoints: ["router2:eth2", "client2:eth1"]
```
## 2. Create Ansible playbooks for router configuration
Next, create a playbook file named `router1.yml` to configure `router1`:
```yaml
---
- name: Configure Arista cEOS Router 1
  hosts: clab-demo-router1
  vars:
    ansible_connection: network_cli
    ansible_network_os: arista.eos.eos
    ansible_host_key_checking: false
    ansible_become: yes
  gather_facts: false
  tasks:
    - name: Configure Ethernet interfaces
      arista.eos.eos_l3_interfaces:
        config:
          - name: Ethernet1
            ipv4:
              - address: 192.168.1.1/30
          - name: Ethernet2
            ipv4:
              - address: 192.168.10.1/24
          - name: Loopback0
            ipv4:
              - address: 10.10.10.1/32              
        state: merged
    - name: Enable Ethernet interfaces
      arista.eos.eos_interfaces:
        config:
          - name: Ethernet1
            enabled: true
            mode: layer3
          - name: Ethernet2
            enabled: true
            mode: layer3            
        state: merged
    - name: Enable IP routing
      arista.eos.eos_config:
        lines:
          - ip routing        
    - name: Configure BGP settings
      arista.eos.eos_bgp_global:
        config:
          as_number: "65001"
          router_id: "10.10.10.1"
          network:
            - address: 192.168.10.0/24
          neighbor:
            - neighbor_address: "192.168.1.2"
              remote_as: "65001"
        state: merged
```
Then, create a second playbook file, `router2.yml`, to configure `router2`:
```yaml
---
- name: Configure Arista cEOS Router 2
  hosts: clab-demo-router2
  vars:
    ansible_connection: network_cli
    ansible_network_os: arista.eos.eos
    ansible_host_key_checking: false
    ansible_become: yes
  gather_facts: false
  tasks:
    - name: Configure Ethernet interfaces
      arista.eos.eos_l3_interfaces:
        config:
          - name: Ethernet1
            ipv4:
              - address: 192.168.1.2/30
          - name: Ethernet2
            ipv4:
              - address: 192.168.20.1/24
          - name: Loopback0
            ipv4:
              - address: 10.10.10.2/32              
        state: merged
    - name: Enable Ethernet interfaces
      arista.eos.eos_interfaces:
        config:
          - name: Ethernet1
            enabled: true
            mode: layer3
          - name: Ethernet2
            enabled: true
            mode: layer3            
        state: merged
    - name: Enable IP routing
      arista.eos.eos_config:
        lines:
          - ip routing        
    - name: Configure BGP settings
      arista.eos.eos_bgp_global:
        config:
          as_number: "65001"
          router_id: "10.10.10.2"
          network:
            - address: 192.168.20.0/24
          neighbor:
            - neighbor_address: "192.168.1.1"
              remote_as: "65001"
        state: merged
```
## 3. Deploy and configure the lab
Deploy the lab using Containerlab:
```
containerlab deploy -t demo.clab.yml
```

![img](../assets/clab.png)

Containerlab automatically generates an Ansible inventory file in the lab directory (e.g., `clab-demo/ansible-inventory.yml`). Use this inventory to run the Ansible playbooks:
```
ansible-playbook -i clab-demo/ansible-inventory.yml router1.yml
ansible-playbook -i clab-demo/ansible-inventory.yml router2.yml
```
After the playbooks have run, you can connect to the clients and routers to test connectivity and inspect the routing tables.
To verify the BGP routing table using Ansible, create a playbook named `verify.yml`:
```yaml
---
- name: Show BGP routing table on Arista cEOS routers
  hosts: arista_ceos
  vars:
    ansible_connection: network_cli
    ansible_network_os: arista.eos.eos
    ansible_host_key_checking: false
  gather_facts: false
  tasks:
    - name: Show BGP routes
      arista.eos.eos_command:
        commands:
          - show ip bgp summary
          - show ip bgp
      register: bgp_output
    - name: Display BGP routes
      ansible.builtin.debug:
        var: bgp_output.stdout_lines
```
Run the playbook:
```
ansible-playbook -i clab-demo/ansible-inventory.yml verify.yml
```
This will display the BGP routing table for both routers.
To destroy the lab and remove all related files, run the following command:
```
containerlab destroy -t demo.clab.yml --cleanup
```

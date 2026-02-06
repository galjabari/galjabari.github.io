---
layout: default
title: "Deploy OSPF Lab with Ansible and Containerlab"
---

# Deploy OSPF Lab with Ansible and Containerlab

This guide demonstrates how to deploy and configure a basic OSPF lab using Ansible and Containerlab. The lab uses a 3-router topology with one spine and two leaf routers, all running Arista cEOS.

The topology is defined in the `ospf.clab.yml` file:

```
name: ospf
topology:
  nodes:
    spine:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
    leaf1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
    leaf2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
  links:
    - endpoints: ["spine:eth1", "leaf1:eth1"]
    - endpoints: ["spine:eth2", "leaf2:eth1"]
```

First, deploy the topology with Containerlab.

```
containerlab deploy -t ospf.clab.yml
```

Then, create Ansible playbooks to configure the network interfaces and set up OSPF on each node.

Create a playbook (`spine.yml`) to configure the spine router:

```yaml
---
- name: Configure Arista cEOS Spine
  hosts: clab-ospf-spine
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
              - address: 192.168.1.5/30
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
    - name: Configure OSPF settings
      arista.eos.eos_ospfv2:
        config:
          processes:
            - process_id: 1
              router_id: "10.10.10.1"
              networks:
                - prefix: "10.10.10.1/32"
                  area: "0.0.0.0"
                - prefix: "192.168.1.0/30"
                  area: "0.0.0.0"
                - prefix: "192.168.1.4/30"
                  area: "0.0.0.0"
        state: merged
```

Create a playbook (`leaf1.yml`) to configure the first leaf router:

```yaml
---
- name: Configure Arista cEOS Leaf 1
  hosts: clab-ospf-leaf1
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
              - address: 192.168.10.1/24
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
    - name: Configure OSPF settings
      arista.eos.eos_ospfv2:
        config:
          processes:
            - process_id: 1
              router_id: "10.10.10.2"
              networks:
                - prefix: "10.10.10.2/32"
                  area: "0.0.0.0"
                - prefix: "192.168.1.0/30"
                  area: "0.0.0.0"
        state: merged
```

Create a playbook (`leaf2.yml`) to configure the second leaf router:

```yaml
---
- name: Configure Arista cEOS Leaf 2
  hosts: clab-ospf-leaf2
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
              - address: 192.168.1.6/30
          - name: Ethernet2
            ipv4:
              - address: 192.168.20.1/24
          - name: Loopback0
            ipv4:
              - address: 10.10.10.3/32
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
    - name: Configure OSPF settings
      arista.eos.eos_ospfv2:
        config:
          processes:
            - process_id: 1
              router_id: "10.10.10.3"
              networks:
                - prefix: "10.10.10.3/32"
                  area: "0.0.0.0"
                - prefix: "192.168.1.4/30"
                  area: "0.0.0.0"
        state: merged
```

Next, execute the playbooks for each device:

```
ansible-playbook -i clab-ospf/ansible-inventory.yml leaf1.yml
ansible-playbook -i clab-ospf/ansible-inventory.yml leaf2.yml
ansible-playbook -i clab-ospf/ansible-inventory.yml spine.yml
```

You can verify the OSPF routing tables using the following Ansible playbook (`verify.yml`):

```yaml
---
- name: Show OSPF routing table on Arista cEOS routers
  hosts: arista_ceos
  vars:
    ansible_connection: network_cli
    ansible_network_os: arista.eos.eos
    ansible_host_key_checking: false
  gather_facts: false
  tasks:
    - name: Show OSPF routes
      arista.eos.eos_command:
        commands: 
          - show ip ospf neighbor
          - show ip route ospf
      register: ospf_output
    - name: Display OSPF routes
      ansible.builtin.debug:
        var: ospf_output.stdout_lines
```

Run the playbook:

```
ansible-playbook -i clab-ospf/ansible-inventory.yml verify.yml
```

---
layout: default
title: "Deploy an STP Lab with Containerlab and Ansible"
---

# Deploy an STP Lab with Containerlab and Ansible

This guide demonstrates how to deploy a Spanning Tree Protocol (STP) lab using Containerlab and verify the configuration with Ansible.

In this lab, we will create a simple topology with three Arista switches, configure them for STP, and use Ansible to verify the STP status.

## 1. Create the lab topology with Containerlab

Use the following YAML configuration (`stp.clab.yml`) to define the lab topology:

```
name: stp
topology:
  nodes:
    s1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    s2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    s3:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
  links:
    - endpoints: ["s1:eth1", "s2:eth1"]
    - endpoints: ["s2:eth2", "s3:eth1"]
    - endpoints: ["s3:eth2", "s1:eth2"]
```

Create a file named `switch.cfg` with the following content:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
spanning-tree mode rapid-pvst
!
interface Ethernet1
  switchport
!
interface Ethernet2
  switchport
!
end
```

## 2. Deploy the lab topology

To deploy the lab, run the following command:

```
containerlab deploy -t stp.clab.yml
```

This command will deploy the lab topology using Docker containers.

![](../assets/stp.png)

## 3. Verify the configuration with Ansible

Use the following Ansible playbook (`show_stp.yml`) to verify the STP status on all switches:

```yaml
---
- name: Show spanning-tree on all switches
  hosts: ceos
  vars:
    ansible_connection: network_cli
    ansible_network_os: arista.eos.eos
    ansible_host_key_checking: false
  gather_facts: false
  tasks:
    - name: Run show spanning-tree
      arista.eos.eos_command:
        commands:
          - show spanning-tree
      register: stp_output
    - name: Display spanning-tree output
      debug:
        var: stp_output.stdout_lines
```

## 4. Run the Ansible playbook

To run the playbook and display the STP status for each switch, use:

```
ansible-playbook -i clab-stp/ansible-inventory.yml show_stp.yml
```

This command will connect to the switches and execute the `show spanning-tree` command. The output will display the STP status for each switch, including information such as the root bridge, port roles, and blocked ports.

## 5. Clean up the lab

After testing, you can clean up the lab environment. To remove the lab and all related files, run:

```
containerlab destroy -t stp.clab.yml --cleanup
```

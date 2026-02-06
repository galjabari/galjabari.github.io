# Network Automation with Ansible

To automate network tasks across a wide range of network devices and platforms, you can use Ansible.

## Install Ansible on Ubuntu

To install Ansible on your Linux machine (control node), run the following commands:

```
sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
```

Verify the installation by checking the Ansible version:

```
ansible --version
```

## Create an Ansible inventory file

To manage network devices with Ansible, you need to install the required Ansible modules. For example, to manage Cisco IOS devices, you need to install the `cisco.ios` collection using the command:

```
ansible-galaxy collection install cisco.ios
```

Once installed, create an inventory file that lists the network devices along with their settings:

```
nano hosts.ini
```

For example, add the following lines to define Cisco switches:

```
[switches]
switch1 ansible_host=192.168.1.1
switch2 ansible_host=192.168.1.2
switch3 ansible_host=192.168.1.3

[switches:vars]
ansible_user=admin
ansible_password=pass@123
ansible_network_os=cisco.ios.ios
ansible_host_key_checking=false
```

Ensure that SSH is configured on Cisco switches for remote management.

## Write an Ansible playbook

To define the configuration tasks, you need to create a playbook file using YAML syntax:

```
nano config_vlans.yml
```

For example, add the following lines to define VLAN configuration tasks:

```yaml
---
- name: Configure VLANs on Cisco switches
  hosts: switches
  connection: network_cli
  gather_facts: false
  tasks:
    cisco.ios.ios_vlans:
      config:
        - vlan_id: 10
          name: VLAN10
        - vlan_id: 20
          name: VLAN20
      state: merged
```

Run the playbook to apply the configuration on Cisco switches:

```
ansible-playbook -i hosts.ini config_vlans.yml
```

Ansible will connect to Cisco switches using SSH, configure the specified VLANs, and report the result.

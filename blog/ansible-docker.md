---
title: "Deploy Docker containers with Ansible"
---

# Deploy Docker containers with Ansible

This guide assumes you have already installed [Ansible on your control node](linux-automation.md) and you need to automate the deployment of Docker containers using Ansible.

## Install Docker using Ansible

To install Docker on your target hosts with Ansible, you need to create an inventory file listing target hosts:

```
nano hosts.ini
```

For example, add the following lines to define Docker hosts:

```
[docker_hosts]
host1 ansible_host=192.168.1.101
host2 ansible_host=192.168.1.102

[docker_hosts:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_host_key_checking=false
```

Ensure that the SSH service is installed and properly configured on the target hosts for connecting with SSH keys.

Create a playbook with tasks to install Docker on the target hosts. For example:

```
nano install_docker.yml
```

Add the following lines into the playbook:

```yaml
---
- name: Install Docker on Ubuntu
  hosts: docker_hosts
  gather_facts: true
  become: yes
  tasks:
    - name: Update package lists
      ansible.builtin.apt:
        update_cache: yes
    - name: Install required packages
      ansible.builtin.apt:
        name:
          - software-properties-common
          - ca-certificates
          - curl
        state: present
    - name: Add Docker's official GPG key
      ansible.builtin.apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present
    - name: Add Docker stable repository
      ansible.builtin.apt_repository:
        repo: "deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present
    - name: Install Docker packages
      ansible.builtin.apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: latest
        update_cache: yes
    - name: Ensure Docker service is started and enabled
      ansible.builtin.service:
        name: docker
        state: started
        enabled: yes
    - name: Add user to the docker group
      ansible.builtin.user:
        name: "{{ ansible_user }}"
        groups: docker
        append: yes
    - name: Verify Docker installation
      ansible.builtin.command: docker --version
      register: docker_version
    - name: Print Docker version
      ansible.builtin.debug:
        var: docker_version.stdout
```

Run the playbook:

```
ansible-playbook -i hosts.ini install_docker.yml
```

After running the playbook, you should be able to pull Docker images and run containers on the target hosts.

## Deploy Docker containers using Ansible

Create a playbook to automate the deployment of Docker containers (e.g., nginx):

```
nano deploy_nginx.yml
```

Add the following lines into the playbook:

```yaml
---
- name: Deploy nginx using Docker
  hosts: docker_hosts
  gather_facts: false
  tasks:
    - name: Ensure Docker is installed
      ansible.builtin.service:
        name: docker
        state: started
      become: true
    - name: Ensure Docker SDK for Python is installed
      ansible.builtin.apt:
        name: python3-docker
        state: present
        update_cache: yes
      become: true
    - name: Pull nginx image
      community.docker.docker_image:
        name: nginx:latest
        source: pull
    - name: Run nginx container
      community.docker.docker_container:
        name: nginx
        image: nginx
        state: started
        ports:
          - "80:80"
        restart_policy: unless-stopped
    - name: Wait for port 80 to become available
      ansible.builtin.wait_for:
        port: 80
        delay: 10
```

Run the playbook:

```
ansible-playbook -i hosts.ini deploy_nginx.yml
```

After running the playbook, open a web browser and enter the IP addresses of Docker hosts; you should see the default nginx page.

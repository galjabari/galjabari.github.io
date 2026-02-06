---
layout: default
title: "Linux Automation with Ansible"
---

# Linux Automation with Ansible

To automate tasks on Linux systems such as installing software, configuring services, and managing users, you can use Ansible automation tool.

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

To manage and configure Linux systems with Ansible, you need to create an inventory file that lists target Linux hosts along with their settings:

```
nano hosts.ini
```

For example, add the following lines to define the target Linux hosts:

```
[linux_hosts]
webserver ansible_host=192.168.1.101
dbserver ansible_host=192.168.1.102

[linux_hosts:vars]
ansible_user=ubuntu
ansible_password=ubuntu
ansible_host_key_checking=false
```

To avoid storing passwords in the inventory file, you can connect to Linux hosts using SSH keys:

```
[linux_hosts]
webserver ansible_host=192.168.1.101
dbserver ansible_host=192.168.1.102

[linux_hosts:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_host_key_checking=false
```

You can generate SSH keys on your machine to connect to the target hosts using the `ssh-keygen` command.

## Write an Ansible playbook

To verify connectivity with the target hosts and ensure the ability to log in, you can use the `ping` module within an Ansible playbook:

```
nano ping.yml
```

Add the following lines in the playbook:

```
---
- hosts: all
  gather_facts: false
  tasks:
    - name: Check connectivity
      ansible.builtin.ping:
```

Run the playbook using the `ansible-playbook` command:

```
ansible-playbook -i hosts.ini ping.yml
```

This will ping all hosts defined in the playbook and return a success response for each host that is reachable.

To define system administration tasks using Ansible, you should create a playbook. For example:

```
nano install_apache.yml
```

Add the following lines to install Apache web server:

```
---
- name: Install Apache on Ubuntu
  hosts: webserver
  gather_facts: false
  become: yes # Run tasks with root privileges
  tasks:
    - name: Update repositories cache and install apache2
      ansible.builtin.apt:
        name: apache2
        state: latest
        update_cache: yes
    - name: Start and enable apache2 service
      ansible.builtin.service:
        name: apache2
        state: started
        enabled: yes
```

Run the playbook:

```
ansible-playbook -i hosts.ini install_apache.yml
```

Open a web browser and enter the IP address of `webserver` in the address bar; you should see the default Apache page.

To configure a new virtual host or site on Apache, you need to create a new playbook file:

```
nano config_vhost.yml
```

Add the following content:

```
---
- name: Configure Apache virtual host
  hosts: webserver
  gather_facts: false
  become: true
  vars:
    site_domain: example.com  # Define your site domain
  tasks:
    - name: Ensure Apache2 is installed
      ansible.builtin.apt:
        name: apache2
        state: present
    - name: Copy Apache virtual host configuration file
      ansible.builtin.template:
        src: vhost.conf.j2  # Path to your Jinja2 template file
        dest: /etc/apache2/sites-available/{{ site_domain }}.conf
      notify:
        - Reload Apache
    - name: Enable the new site
      ansible.builtin.command: a2ensite {{ site_domain }}
      notify:
        - Reload Apache
    - name: Create directory for site content
      ansible.builtin.file:
        path: "/var/www/{{ site_domain }}"
        state: directory
        owner: www-data
        group: www-data
        mode: '0755'
    - name: Create default page
      ansible.builtin.copy:
        content: '<h1>Welcome to {{ site_domain }}</h1>'
        dest: /var/www/{{ site_domain }}/index.html
  handlers:
    - name: Reload Apache
      ansible.builtin.service:
        name: apache2
        state: reloaded
```

Replace `example.com` with your desired domain name for the new virtual host.

Create a Jinja2 template file:

```
nano vhost.conf.j2
```

Add the following content:

```
<VirtualHost *:80>
    ServerAdmin webmaster@{{ site_domain }}
    ServerName {{ site_domain }}
    ServerAlias www.{{ site_domain }}
    DocumentRoot /var/www/{{ site_domain }}/
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Run the playbook:

```
ansible-playbook -i hosts.ini config_vhost.yml
```

After running the playbook, you should be able to access `http://example.com` and see the default page you've configured.

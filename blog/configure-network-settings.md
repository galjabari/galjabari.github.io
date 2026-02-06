---
layout: default
title: "Configure network settings on Ubuntu"
---

# Configure network settings on Ubuntu

Ubuntu provides graphical utilities for configuring network interfaces. To manage network settings from the command-line interface (CLI), you can use tools like `ip addr` or `ifconfig`.

To identify all available network interfaces, run the following command:

```
ip a
```

The system identifies Ethernet interfaces with logical names such as `ens3` or `enp2s0`.

## Configure a dynamic IP address

Netplan configuration files are located in the `/etc/netplan/` directory and use the `.yaml` format. To configure an interface to use DHCP, edit the relevant configuration file. For example:

```
sudo nano /etc/netplan/50-cloud-init.yaml
```

Add the following configuration:

```
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
```

This configuration enables dynamic IP address assignment (DHCP) for the Ethernet interface identified as `ens3`.

To apply the configuration, run the following command:

```
sudo netplan apply
```

## Configure a static IP address

To assign a static IP address, edit the Netplan configuration file:

```
sudo nano /etc/netplan/50-cloud-init.yaml
```

For example, add the following configuration:

```
network:
  version: 2
  ethernets:
    ens33:
      addresses:
        - 192.168.1.20/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        search: [example.com]
        addresses: [192.168.1.10, 192.168.1.11]
```

Adjust the settings, such as the IP address, default gateway, search domain, and DNS servers, to match your network requirements.

Apply the configuration:

```
sudo netplan apply
```

## Configure multiple interfaces

To configure multiple network interfaces, edit the Netplan configuration file:

```
sudo nano /etc/netplan/50-cloud-init.yaml
```

For example, add the following configuration for two interfaces:

```
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: true
    ens37:
      addresses:
        - 192.168.1.10/24
```

Apply the configuration:

```
sudo netplan apply
```

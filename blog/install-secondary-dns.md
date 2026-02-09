---
layout: default
title: "Install and configure a secondary DNS Server on Ubuntu"
---

# Install and configure a secondary DNS Server on Ubuntu

This guide assumes you have already configured [DNS Server](install-dns-server.md) as a primary server, and you need to set up a secondary server to maintain the availability of the domain if the primary becomes unavailable.

## Configure primary DNS server

First, on the primary server, edit the BIND configuration file.

```bash
sudo nano /etc/bind/named.conf.local
```

Add `allow-transfer` option to the zone and `also-notify` to notify the secondary server of zone changes.

```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
    allow-transfer { 192.168.1.11; };
    also-notify { 192.168.1.11; };
};
```

Replace `192.168.1.11` with the IP address of your secondary server.

Edit the zone file for your domain.

```bash
sudo nano /etc/bind/db.example.com
```

Add the following lines under the existing records:

```
@       IN      NS      ns2.example.com.
ns2     IN      A       192.168.1.11
```

After making changes, restart the BIND service to apply the configuration.

```bash
sudo systemctl restart bind9.service
```

Verify that BIND is running without errors.

```bash
sudo systemctl status bind9.service
```

Finally, test DNS resolution to list nameserver records for your domain.

```bash
dig NS example.com
```

You should see the DNS records returned by your primary DNS server.

## Configure secondary DNS server

Before setting up the secondary DNS server, ensure that your system has a static IP address (e.g., `192.168.1.11/24`)

Next, update the package lists, similar to the primary server.

```bash
sudo apt update
```

Install the BIND DNS server package.

```bash
sudo apt install bind9 -y
```

Edit the BIND configuration file to define the zone.

```bash
sudo nano /etc/bind/named.conf.local
```

Add the following configuration for your domain:

```
zone "example.com" {
    type slave;
    file "db.example.com";
    masters { 192.168.1.10; };
};
```

Replace `192.168.1.10` with the IP address of your primary server.

To apply the changes, restart the BIND service.

```bash
sudo systemctl restart bind9.service
```

To query your secondary DNS server directly, use the `dig` command with the @ symbol followed by the hostname or IP address of the server:

```bash
dig www.example.com @192.168.1.11
```

Note: A zone is only transferred if the `Serial` number on the primary server is larger than the one on the secondary server. You must increment the `Serial` number every time you make changes to the zone file on the primary server.

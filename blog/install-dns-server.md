---
title: "Install and configure an authoritative DNS Server on Ubuntu"
description: "A step-by-step guide on how to install and configure an authoritative DNS server on Ubuntu 20.04/22.04 using BIND"
---

# Install and configure an authoritative DNS Server on Ubuntu

Before setting up the DNS server, ensure that your system has a static IP address (for example, `192.168.1.10/24`).

First, update the package lists to ensure you install the latest versions of packages.

```
sudo apt update
```

Install the BIND DNS server package.

```
sudo apt install bind9 -y
```

Edit the BIND configuration file to define the zone.

```
sudo nano /etc/bind/named.conf.local
```

Add the following configuration for your domain, replacing `example.com` with your actual domain name:

```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com";
};
```

Copy the default zone file and create a new one for your domain.

```
sudo cp /etc/bind/db.local /etc/bind/db.example.com
```

Edit the newly created zone file for your domain.

```
sudo nano /etc/bind/db.example.com
```

Replace the contents with the following, updating with your actual domain name and IP addresses:

```
$TTL    604800
@       IN      SOA     example.com. admin.example.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
@       IN      NS      ns1.example.com.
ns1     IN      A       192.168.1.10
@       IN      A       192.168.1.12
```

After making changes, restart the BIND service to apply the configuration.

```
sudo systemctl restart bind9.service
```

Verify that BIND is running without errors.

```
sudo systemctl status bind9.service
```

Finally, test DNS resolution for your domain.

```
dig example.com
```

You should see the DNS records returned by your authoritative DNS server.

To add a new DNS record for `www.example.com` pointing to `example.com`, edit the zone file.

```
sudo nano /etc/bind/db.example.com
```

Add the following line under the existing records:

```
www     IN      CNAME   example.com.
```

After adding the new DNS record, restart the BIND service to apply the changes.

```
sudo systemctl restart bind9.service
```

Finally, test DNS resolution for the newly added domain name.

```
dig www.example.com
```

You should see the DNS records returned by your authoritative DNS server.

To query your DNS server directly, use the @ symbol followed by the IP address of the server:

```
dig www.example.com @192.168.1.10
```

This command queries the DNS server instead of using the default DNS server configured on your system.

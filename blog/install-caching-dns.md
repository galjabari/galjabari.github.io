---
layout: default
title: "Install and configure a caching DNS server on Ubuntu"
---

# Install and configure a caching DNS server on Ubuntu

Before setting up the DNS server, ensure that your system has a static IP address (for example, `192.168.1.10/24`).

First, update the package list to ensure you have the latest version of packages available:

```bash
sudo apt update
```

Install the BIND package, which is the DNS server software:

```bash
sudo apt install bind9 -y
```

Edit the BIND configuration file named `named.conf.options` using a text editor. Here, we'll use `nano`:

```bash
sudo nano /etc/bind/named.conf.options
```

Inside the file, locate the `forwarders` section and add the following lines with the IP addresses of your desired DNS servers (for example, Google's public DNS servers):

```
forwarders {
  8.8.8.8;
  8.8.4.4;
};
```

Replace 8.8.8.8 and 8.8.4.4 with your preferred DNS server IPs if desired.

Save the changes and exit the text editor (in `nano`, press Ctrl + X, then Y, and Enter to confirm).

To apply the changes made to the configuration file, restart the BIND service:

```bash
sudo systemctl restart bind9.service
```

Check the status of the BIND service to ensure it restarted without errors:

```bash
sudo systemctl status bind9.service
```

Finally, test the DNS resolution using the `dig` command. Here's an example with www.google.com:

```bash
dig www.google.com
```

You should see output containing information about the DNS query, including the IP address(es) associated with the domain.

To query a specific DNS server directly, use the @ symbol followed by the IP address of the server. For example:

```bash
dig www.google.com @192.168.1.10
```

This command queries the DNS server instead of using the default DNS server configured on your system.

You can now use this server for DNS resolution on your network.

---
layout: default
title: "Install and Configure a DHCP Server on Ubuntu"
---

# Install and Configure a DHCP Server on Ubuntu

Before setting up the DHCP server, ensure that your system has a static IP address (for example, `192.168.1.5/24`).

First, update your system's package lists by running:

```
sudo apt update
```

Install the DHCP server package:

```
sudo apt install isc-dhcp-server -y
```

Open the DHCP server configuration file in the `nano` text editor:

```
sudo nano /etc/dhcp/dhcpd.conf
```

Inside the editor, replace any existing content with the following configuration:

```
subnet 192.168.1.0 netmask 255.255.255.0 {
  range 192.168.1.100 192.168.1.200;
  option routers 192.168.1.1;
  option domain-name-servers 192.168.1.10, 192.168.1.11;
  option domain-name "example.com";
  default-lease-time 600;
  max-lease-time 7200;
}
```

This configuration specifies the subnet, IP range, default gateway (router), DNS servers, domain name, default lease time, and maximum lease time.

After making changes, save the file by pressing Ctrl + O, then press Enter, and exit nano by pressing Ctrl + X.

If you have multiple network interfaces, you need to specify which interface the DHCP server should listen on. Edit the following file:

```
sudo nano /etc/default/isc-dhcp-server
```

For example, set the interface:

```
INTERFACESv4="ens37"
```

Replace `ens37` with your actual network interface name (use `ip a` to check).

Restart the DHCP service to apply the new configuration:

```
sudo systemctl restart isc-dhcp-server.service
```

Verify that the DHCP service is running without errors by checking its status:

```
sudo systemctl status isc-dhcp-server.service
```

If everything is configured correctly, you should see a message indicating that the service is active and running.

It will now assign IP addresses automatically to devices on your network.

To list the DHCP leases on the DHCP server, you can run the following command:

```
dhcp-lease-list
```

This command is used to monitor IP address assignments within your network.

To assign a static IP address to a device in the DHCP server, you need to edit the DHCP configuration file:

```
sudo nano /etc/dhcp/dhcpd.conf
```

Add a host declaration for the device within the subnet section. For example:

```
host printer1 {
    hardware etherenet 00:11:22:33:44:55;
    fixed-address 192.168.1.100;
}
```

In this example, a printer with the MAC address `00:11:22:33:44:55` is assigned the static IP address `192.168.1.100`.

Restart the DHCP server to apply the changes:

```
sudo systemctl restart isc-dhcp-server.service
```

Ensure the printer is configured to request an IP address form the DHCP server.

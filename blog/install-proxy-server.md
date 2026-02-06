---
layout: default
title: "Install a Proxy Server on Ubuntu"
---

# Install a Proxy Server on Ubuntu

Update package lists and install Squid proxy server.

```
sudo apt update
sudo apt install squid -y
```

Edit the Squid configuration file using a text editor.

```
sudo nano /etc/squid/squid.conf
```

In the `nano` text editor, you can search for a term by pressing Ctrl + W, then pressing Enter.

Inside the file, locate the `http_access` section and uncomment the following line to allow access from your local network:

```
http_access allow localnet
```

To apply the changes made to the configuration file, save the file and restart the Squid service.

```
sudo systemctl restart squid.service
```

Check the status of the Squid service to ensure it restarts without errors.

```
sudo systemctl status squid.service
```

You can now connect to this proxy server from your client devices. Enter the IP address of your proxy server and the port number (the default port for Squid is 3128) in your device's proxy settings. Once you've configured the proxy settings on your device, it will route all internet traffic through the Squid proxy server.

To monitor access to your proxy server in real-time, you can tail the access log.

```
sudo tail -f /var/log/squid/access.log
```

To block specific websites, edit the Squid configuration file again.

```
sudo nano /etc/squid/squid.conf
```

As an example, add the following lines to the top of the `http_access` section that allows network access:

```
acl blocklist dstdomain .facebook.com .youtube.com
http_access deny blocklist
```

After updating the configuration file, you will need to save the file and reload the Squid service for changes to take effect.

```
sudo systemctl reload squid.service
```

Using access control in Squid, you can manage and restrict access to internet services through the proxy server.

# OpenVPN with RADIUS for ZTNA

This guide explains how to implement Zero Trust Network Access (ZTNA) using OpenVPN and FreeRADIUS, with the goal of enforcing a zero trust approach: never trust, always verify.

Before you begin, make sure to complete the following guide:
[Configure OpenVPN with RADIUS authentication](openvpn-radius.md)

## 1. Configure RADIUS server

Edit the users configuration file of FreeRADIUS:

```
sudo nano /etc/freeradius/3.0/users
```

Add the following lines to assign a static IP address to a user:

```
vpnuser Cleartext-Password := "secret"
        Service-Type = Framed-User,
        Framed-IP-Address = 10.8.0.33
```

Restart the FreeRADIUS service to apply the changes:

```
sudo systemctl restart freeradius.service
```

Check the status to ensure it is running correctly:

```
sudo systemctl status freeradius.service
```

Test the RADIUS user authentication:

```
radtest vpnuser secret localhost 0 testing123
```

## 2. Configure OpenVPN server

Create a directory for client-specific configurations in OpenVPN:

```
sudo mkdir -p /etc/openvpn/ccd
```

Edit the OpenVPN server configuration file:

```
sudo nano /etc/openvpn/server/server.conf
```

Add or modify the following lines:

```
#push "redirect-gateway def1 bypass-dhcp"
push "route 192.168.1.0 255.255.255.0"
push "dhcp-option DNS 192.168.1.10"
client-config-dir /etc/openvpn/ccd
username-as-common-name
```

This configuration pushes the route to the internal LAN, sets the DNS server for VPN clients, and enables client-specific configurations. Ensure you comment out the `redirect-gateway` line, if present, to prevent internet access through the VPN.

Edit the OpenVPN RADIUS plugin configuration file:

```
sudo nano /etc/openvpn/radiusplugin.cnf
```

Ensure the following line is present to enable client-specific configurations:

```
client-config-dir /etc/openvpn/ccd
```

Restart the OpenVPN server to apply the changes:

```
sudo systemctl restart openvpn-server@server.service
```

Check the status to ensure it is running correctly:

```
sudo systemctl status openvpn-server@server.service
```

To verify the setup, connect to the VPN using the configured user credentials. Once connected, check the assigned IP address and routing table.

## 3. Create a script for OpenVPN

To enhance logging and monitoring, you can create a script that logs connection and disconnection events. For example, edit the server configuration file:

```
sudo nano /etc/openvpn/server/server.conf
```

Add the following lines:

```
script-security 2
client-connect /etc/openvpn/client-events.sh
client-disconnect /etc/openvpn/client-events.sh
```

Create the script file:

```
sudo nano /etc/openvpn/client-events.sh
```

Add the following content:

```
#!/bin/bash
LOGFILE="/var/log/openvpn/clients.log"
DATE_TIME=$(date +"%Y-%m-%d %H:%M:%S")
if [ "$script_type" = "client-connect" ]; then
    echo "$DATE_TIME [CONNECT] CN=$common_name REAL_IP=$untrusted_ip \
VIRTUAL_IP=$ifconfig_pool_remote_ip" >> "$LOGFILE"
else
    echo "$DATE_TIME [DISCONNECT] CN=$common_name REAL_IP=$untrusted_ip \
VIRTUAL_IP=$ifconfig_pool_remote_ip RX=${bytes_received}B TX=${bytes_sent}B" \
    >> "$LOGFILE"
fi
exit 0
```

Make sure the script is executable:

```
sudo chmod +x /etc/openvpn/client-events.sh
```

Create the log file and set permissions:

```
sudo touch /var/log/openvpn/clients.log
sudo chown nobody:nogroup /var/log/openvpn/clients.log
```

Restart the OpenVPN server to apply the changes:

```
sudo systemctl restart openvpn-server@server.service
```

Now, connection and disconnection events will be logged in `/var/log/openvpn/clients.log`.

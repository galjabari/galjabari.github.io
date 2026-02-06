# Configure OpenVPN with RADIUS authentication

This guide walks you through setting up OpenVPN with RADIUS authentication. It assumes you have a working OpenVPN server and a FreeRADIUS server installed on Ubuntu.

Before proceeding, ensure you have completed the following guides:
[Install and configure RADIUS Server on Ubuntu](install-radius-server.md)
[Install OpenVPN Server on Ubuntu](install-openvpn.md)

## 1. Configure RADIUS server

Edit the FreeRADIUS client configuration file:

```
sudo nano /etc/freeradius/3.0/clients.conf
```

Add a client entry for your OpenVPN server, replacing `OPENVPN_IP` with its IP address and `SHARED_SECRET` with the shared secret.

```
client openvpn {
    ipaddr          = OPENVPN_IP
    secret          = SHARED_SECRET
}
```

Restart the FreeRADIUS service to apply the changes:

```
sudo systemctl restart freeradius.service
```

## 2. Configure OpenVPN server

Install the OpenVPN RADIUS authentication plugin:

```
sudo apt-get install openvpn-auth-radius -y
```

Copy the example configuration file for the RADIUS plugin:

```
sudo cp /usr/share/doc/openvpn-auth-radius/examples/radiusplugin.cnf /etc/openvpn/radiusplugin.cnf
```

Edit the RADIUS plugin configuration file:

```
sudo nano /etc/openvpn/radiusplugin.cnf
```

Add or modify the following lines, replacing `OPENVPN_IP` with your OpenVPN server's IP address, `FREERADIUS_IP` with your FreeRADIUS server's IP address, and setting a strong `SHARED_SECRET`.

```
NAS-Identifier=openvpn
Service-Type=5
Framed-Protocol=1
NAS-Port-Type=5
NAS-IP-Address=OPENVPN_IP
OpenVPNConfig=/etc/openvpn/server/server.conf
subnet=255.255.255.0
overwriteccfiles=true
server
{
    acctport=1813
    authport=1812
    name=FREERADIUS_IP
    retry=1
    wait=1
    sharedsecret=SHARED_SECRET
}
```

Edit the OpenVPN server configuration file:

```
sudo nano /etc/openvpn/server/server.conf
```

Add the following line to enable the RADIUS plugin:

```
plugin /usr/lib/openvpn/radiusplugin.so /etc/openvpn/radiusplugin.cnf
```

Restart the OpenVPN server service to apply the changes:

```
sudo systemctl restart openvpn-server@server.service
```

Check the status of the OpenVPN server service:

```
sudo systemctl status openvpn-server@server.service
```

## 3. Configure OpenVPN client

To connect an OpenVPN client to the server, modify the client configuration file (e.g., `client.ovpn`):

```
sudo nano client.ovpn
```

Add the following line to your client configuration:

```
auth-user-pass
```

This prompts the user for a username and password when connecting to the OpenVPN server. You can then transfer this file to your OpenVPN client.

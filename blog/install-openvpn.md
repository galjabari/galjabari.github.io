# Install OpenVPN Server on Ubuntu

OpenVPN is a popular VPN solution that allows you to create secure point-to-point or site-to-site connections. It uses SSL/TLS for key exchange and supports a wide range of encryption algorithms.

This guide provides a simple way to install OpenVPN server using a bash script. The script automates the entire installation process of OpenVPN, making it easy to set up a secure VPN server.

Download the OpenVPN installation script.

```
wget https://git.io/vpn -O openvpn-install.sh
```

Make the script executable.

```
chmod +x openvpn-install.sh
```

Execute the script with root privileges:

```
sudo ./openvpn-install.sh
```

The script will guide you through the configuration process, asking for details such as the public IP address, DNS servers, and client name. Follow the on-screen prompts to complete the installation.

Once the installation is complete, the script will generate a client configuration file (e.g., `client.ovpn`). You can then transfer this file to your OpenVPN client to connect to the server. New clients can be added by running the script again.

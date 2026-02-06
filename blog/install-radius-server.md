# Install and configure RADIUS Server on Ubuntu

First, update the package lists to ensure you have the latest versions available:

```
sudo apt update
```

Install FreeRADIUS server using the following command:

```
sudo apt-get install freeradius -y
```

Switch to the `root` user to modify the configuration files of FreeRADIUS:

```
sudo -i
```

Edit the clients configuration file using a text editor:

```
nano /etc/freeradius/3.0/clients.conf
```

You need to define each client that will communicate with the server to authenticate users. This could include devices such as access points, VPN servers, switches, or routers.

Add your client information. For example, add the following lines:

```
client switch1 {
    ipaddr          = 192.168.1.254
    secret          = pass@123
}
```

Replace `switch1` client with your own client identifier, IP address, and shared secret.

Edit the users configuration file:

```
nano /etc/freeradius/3.0/users
```

Add user authentication information. For example, uncomment the following line:

```
bob Cleartext-Password := "hello"
```

Replace `bob` user and `secret` password with your own username and password.

Edit the EAP configuration file:

```
nano /etc/freeradius/3.0/mods-available/eap
```

Add or modify the following line to set the default EAP type to PEAP:

```
default_eap_type = peap
```

This configuration is used to ensure compatibility with a broader range of devices such as smartphones, tablets, and computers.

Restart the FreeRADIUS service to apply the changes:

```
systemctl restart freeradius.service
```

Enable the FreeRADIUS service to start automatically on system boot:

```
systemctl enable freeradius.service
```

To verify that your RADIUS server is configured correctly, run the following command:

```
radtest bob hello localhost 0 testing123
```

The output of `radtest` will indicate whether the authentication message was successful or not.

To monitor the RADIUS server's activity in real-time, stop the FreeRADIUS service temporarily and run the FreeRADIUS in debug mode:

```
systemctl stop freeradius.service
freeradius -X
```

Open another terminal window and test the connection using the `radtest` command. Exit FreeRADIUS debug mode by pressing Ctrl + C in the terminal running FreeRADIUS and start the FreeRADIUS service:

```
systemctl start freeradius.service
```

If everything is configured correctly, you can use the RADIUS server to setup your client or any other network device that requires user authentication.

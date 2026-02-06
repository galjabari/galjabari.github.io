---
layout: default
title: "Configure FreeRADIUS with LDAP authentication"
---

# Configure FreeRADIUS with LDAP authentication

Before configuring FreeRADIUS to use an LDAP server for authentication, you need to complete the following guides:
[Install and configure LDAP Server on Ubuntu](install-ldap-server.md)
[Install and configure RADIUS Server on Ubuntu](install-radius-server.md)

Next, install the LDAP module for FreeRADIUS:

```
sudo apt-get install freeradius-ldap -y
```

Switch to the `root` user to modify the configuration files of FreeRADIUS:

```
sudo -i
```

Edit the FreeRADIUS configuration file to add LDAP support:

```
nano /etc/freeradius/3.0/sites-available/default
```

Inside the configuration file, uncomment the following lines in the `authenticate` section:

```
Auth-Type LDAP {
    ldap
}
```

Edit the LDAP module configuration file to add LDAP server settings:

```
nano /etc/freeradius/3.0/mods-available/ldap
```

Then, modify the following parameters:

```
server = 'localhost'
identity = 'cn=admin,dc=example,dc=com'
password = secret
base_dn = 'dc=example,dc=com'
```

Replace the LDAP server details such as base DN, admin credentials, and hostname with your actual LDAP server information.

Create a symbolic link to enable the LDAP module:

```
ln -s /etc/freeradius/3.0/mods-available/ldap /etc/freeradius/3.0/mods-enabled/ldap
```

To apply the changes, restart the FreeRADIUS service:

```
systemctl restart freeradius.service
```

Finally, test LDAP authentication using the `radtest` command:

```
radtest user1 secret localhost 0 testing123
```

Replace `user1` with a valid username and `secret` with the user's password.

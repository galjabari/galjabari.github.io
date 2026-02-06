---
layout: default
title: "OpenVPN with RADIUS and LDAP for ZTNA"
---

# OpenVPN with RADIUS and LDAP for ZTNA

This guide explains how to implement Zero Trust Network Access (ZTNA) using OpenVPN, FreeRADIUS and OpenLDAP. It enables the enforcement of VPN access policies based on LDAP group membership or specific LDAP attributes.

Before proceeding, ensure you have completed the following guides:
[Configure FreeRADIUS with LDAP authentication](configure-freeradius-ldap.md)
[OpenVPN with RADIUS for ZTNA](openvpn-ztna.md)

## Configure FreeRADIUS for LDAP group membership

To create access policies based on LDAP group membership, we need to modify the FreeRADIUS configuration.

```
sudo nano /etc/freeradius/3.0/sites-available/default
```

Inside the configuration file, uncomment the following lines in the `authorize` section:

```
authorize {
    ...
    ldap
    ...
}
```

Edit the LDAP module configuration file:

```
sudo nano /etc/freeradius/3.0/mods-available/ldap
```

Then, modify the following parameters:

{% raw %}
```
filter = '(objectClass=groupOfNames)'
name_attribute = cn
membership_filter = "(|(member=%{control:${..user_dn}})(memberUid=%{%{Stripped-User-Name}:-%{User-Name}}))"
```
{% endraw %}

For example, to restrict VPN access to members of a specific LDAP group (e.g., `group1`), modify the FreeRADIUS configuration file:

```
sudo nano /etc/freeradius/3.0/sites-available/default
```

Locate the `authorize` section and add the following policy.

```
if (LDAP-Group == "group1") {
    update reply {
        Reply-Message = "Access Granted"
    }
} else {
    update reply {
        Reply-Message = "Access Denied: Not a member of the VPN group."
    }
    reject
}
```

To apply the changes, restart the FreeRADIUS service:

```
sudo systemctl restart freeradius.service
```

Test LDAP authentication with group membership using the `radtest` command.

```
radtest user1 secret localhost 0 testing123
```

You should see a message indicating whether access is granted or denied based on group membership.

## Configure FreeRADIUS for LDAP attributes

We can also create access policies based on specific LDAP attributes. For example, to assign static IP addresses to VPN users, extend the OpenLDAP schema with FreeRADIUS attributes:

```
gunzip -c /usr/share/doc/freeradius/schemas/ldap/openldap/freeradius.ldif.gz > freeradius.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f freeradius.ldif
```

Verify that the schema has been loaded correctly:

```
sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config
```

Restart the OpenLDAP service to apply the changes:

```
sudo systemctl restart slapd
```

Next, edit the FreeRADIUS LDAP module configuration file:

```
sudo nano /etc/freeradius/3.0/mods-enabled/ldap
```

Add the following line within the `update` section to map the `Framed-IP-Address` attribute:

```
update {
  reply:Framed-IP-Address := 'radiusFramedIPAddress'
}
```

Restart the FreeRADIUS service to apply the changes:

```
sudo systemctl restart freeradius.service
```

Now, modify LDAP users to include the `radiusFramedIPAddress` attribute, which specifies the static IP address assigned to the user upon VPN connection.

Create a file named `user.ldif`:

```
nano user.ldif
```

Add the following content to the `user1` LDAP entry:

```
dn: uid=user1,ou=People,dc=example,dc=com
changetype: modify
add: objectClass
objectClass: radiusProfile
-
add: radiusFramedIPAddress
radiusFramedIPAddress: 10.8.0.100
```

Apply the changes to the LDAP directory:

```
ldapmodify -x -D "cn=admin,dc=example,dc=com" -W -f user.ldif
```

Test LDAP authentication again using the `radtest` command.

```
radtest user1 secret localhost 0 testing123
```

Now, when `user1` connects to the VPN, they should be assigned the static IP address.

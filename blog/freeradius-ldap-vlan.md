---
title: "Configure FreeRADIUS with LDAP for dynamic VLAN assignment"
description: "A step-by-step guide on how to configure FreeRADIUS on Ubuntu 20.04/22.04 to assign VLANs to users based on LDAP group membership"
---

# Configure FreeRADIUS with LDAP for dynamic VLAN assignment

This guide assumes you have already configured [FreeRADIUS with LDAP authentication](configure-freeradius-ldap.md) and you need to assign VLANs to users based on LDAP group membership.

First, ensure that the LDAP module is enabled in the FreeRADIUS configuration by editing the `default` site configuration file:

```
sudo nano /etc/freeradius/3.0/sites-available/default
```

In the `authorize` section, ensure that the LDAP module is enabled (not commented out):

```
authorize {
    ...
    ldap
    ...
}
```

Edit the LDAP module configuration to set up group lookups:

```
sudo nano /etc/freeradius/3.0/mods-available/ldap
```

Configure the group membership settings:

```
filter = '(objectClass=groupOfNames)'
name_attribute = cn
membership_filter = "(|(member=%{control:${..user_dn}})(memberUid=%{%{Stripped-User-Name}:-%{User-Name}}))"
```

## Configure VLAN assignment

Edit the FreeRADIUS `default` site configuration to add VLAN assignment logic:

```
sudo nano /etc/freeradius/3.0/sites-available/default
```

In the `post-auth` section, add the following configuration to assign VLANs based on LDAP groups:

```
post-auth {
    ...
    if (LDAP-Group == "staff") {
        update reply {
            Tunnel-Type := VLAN
            Tunnel-Medium-Type := IEEE-802
            Tunnel-Private-Group-Id := "10"
        }
    }
    elsif (LDAP-Group == "students") {
        update reply {
            Tunnel-Type := VLAN
            Tunnel-Medium-Type := IEEE-802
            Tunnel-Private-Group-Id := "20"
        }
    }
    ...
}
```

This configuration assigns VLAN 10 to users in the `staff` group and VLAN 20 to users in the `students` group.

## Configure the NAS

Ensure your Network Access Server (NAS) is configured to support dynamic VLAN assignment. For Cisco switches, you may need to configure:

```
interface GigabitEthernet0/1
 switchport mode access
 switchport access vlan 1
 authentication port-control auto
 dot1x pae authenticator
```

## Test the configuration

Restart FreeRADIUS to apply the changes:

```
sudo systemctl restart freeradius.service
```

Test authentication with a user from each group:

```
radtest user1 secret localhost 0 testing123
```

The response should include the Tunnel attributes specifying the VLAN assignment.

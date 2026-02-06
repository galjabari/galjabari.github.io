---
layout: default
title: "Configure FreeRADIUS with LDAP authorization"
---

# Configure FreeRADIUS with LDAP authorization

This guide assumes you have already configured [FreeRADIUS with LDAP authentication](configure-freeradius-ldap.md) and you need to authorize users based on LDAP group membership.

First, switch to the `root` user to modify the configuration files of FreeRADIUS:

```
sudo -i
```

Edit the FreeRADIUS configuration file:

```
nano /etc/freeradius/3.0/sites-available/default
```

Enable LDAP module by removing `-` from `-ldap` in the `authorize` section:

```
authorize {
    ...
    ldap
    ...
}
```

Edit the LDAP module configuration file to configure LDAP group lookups:

```
nano /etc/freeradius/3.0/mods-available/ldap
```

Uncomment and update the following lines:

```
filter = '(objectClass=groupOfNames)'
name_attribute = cn
membership_filter = "(|(member=%{control:${..user_dn}})(memberUid=%{%{Stripped-User-Name}:-%{User-Name}}))"
```

## Configure authorization policies

To define the access policies that grant or deny access based on LDAP group membership, edit the FreeRADIUS configuration file:

```
nano /etc/freeradius/3.0/sites-available/default
```

Look for `authorize` section and add the following lines under `ldap` to grant access to only users belonging to `group1` group:

```
if (LDAP-Group == "group1") {
    noop
} else {
    reject
}
```

To apply the changes, restart the FreeRADIUS service:

```
systemctl restart freeradius.service
```

Check the status of the FreeRADIUS service to ensure it restarted without errors.

```
systemctl status freeradius.service
```

Finally, use `radtest` command to ensure that users are being authenticated and authorized correctly based on LDAP group membership.

```
radtest user1 secret localhost 0 testing123
```

If `user1` is a member of the `group1` group, FreeRADIUS should grant access. If not, access is rejected.

## Configure user profiles

To restrict access based on LDAP groups, you can also define a policy in user profiles by editing the following file:

```
nano /etc/freeradius/3.0/mods-config/files/authorize
```

For example, add the following line to reject access to users belonging to `group2` group:

```
DEFAULT LDAP-Group == "group2", Auth-Type := Reject
```

To apply the changes, restart the FreeRADIUS service.

```
systemctl restart freeradius.service
```

Test the configuration using `radtest` command.

```
radtest user2 secret localhost 0 testing123
```

If `user2` is a member of the `group2` group, FreeRADIUS should reject access.

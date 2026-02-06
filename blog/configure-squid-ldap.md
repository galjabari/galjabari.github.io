---
layout: default
title: "Configure Squid proxy with LDAP authentication"
---

# Configure Squid proxy with LDAP authentication

Before configuring Squid proxy to use an LDAP server for authentication, you need to complete the following guides:
- [Install and configure LDAP Server on Ubuntu](install-ldap-server.md)
- [Install and configure Proxy Server on Ubuntu](install-proxy-server.md)

Next, edit the Squid configuration file using the following command:

```
sudo nano /etc/squid/squid.conf
```

Add the following lines to the top of `http_access` section to configure LDAP authentication:

```
auth_param basic program /usr/lib/squid/basic_ldap_auth -v 3 \
-b "dc=example,dc=com" \
-D "cn=admin,dc=example,dc=com" -w secret \
-f "uid=%s" localhost
auth_param basic children 5 startup=5 idle=1
auth_param basic realm Proxy Authentication Required
auth_param basic credentialsttl 30 minute
acl ldap-auth proxy_auth REQUIRED
http_access allow ldap-auth
```

Make sure to replace the LDAP server details such as base DN, admin credentials, and hostname with your actual LDAP server information.

Remove the following line by commenting it out to restrict access to authenticated users:

```
#http_access allow localnet
```

After making changes, reload the Squid service to apply the configuration:

```
sudo systemctl reload squid.service
```

You can now connect to proxy server from your client devices using LDAP username and password.

To configure Squid for group-based access control using LDAP, you need to define an external ACL type for LDAP group. Edit the Squid configuration file again:

```
sudo nano /etc/squid/squid.conf
```

Add the following lines to define an external ACL type named `ldap_group`:

```
external_acl_type ldap_group %LOGIN /usr/lib/squid/ext_ldap_group_acl -v 3 \
-b "ou=Groups,dc=example,dc=com" \
-D "cn=admin,dc=example,dc=com" -w secret \
-f "(&(cn=%g)(member=uid=%u,ou=People,dc=example,dc=com))" localhost
acl ldap-group1 external ldap_group group1
http_access allow ldap-group1
```

This configuration allows access for users that are members of the group named `group1` in the LDAP directory. Replace LDAP server details such as base DN, admin credentials, and hostname with your actual LDAP server information. You can create multiple ACLs for different LDAP groups by adding more `http_access` rules accordingly.

Make sure to remove the following line by commenting it out to restrict access to members of the LDAP group:

```
#http_access allow ldap-auth
```

After making changes, reload the Squid service to apply the configuration:

```
sudo systemctl reload squid.service
```

Ensure that there are no syntax errors in the configuration file before reloading the service.

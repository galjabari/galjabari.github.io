---
layout: default
title: "Install and Configure LDAP Server on Ubuntu"
---

# Install and Configure LDAP Server on Ubuntu

First, set the hostname within your domain. Replace `example.com` with your actual domain.

```
sudo hostname ldap.example.com
```

Next, update package lists and install OpenLDAP and related utilities.

```
sudo apt update
sudo apt install slapd ldap-utils -y
```

After installation, you will be prompted to configure the OpenLDAP server. When prompted to set up your LDAP administrator password, enter a new password and then confirm it.

You can also reconfigure the OpenLDAP server anytime using:

```
sudo dpkg-reconfigure slapd
```

Step 1: Select No if you want to omit the OpenLDAP server configuration.
Step 2: Enter your domain name, which will become your base Distinguished Name (DN). If you enter `example.com`, it is converted to `dc=example,dc=com`.
Step 3: Enter your organization name, such as "Example".
Step 4: Enter your LDAP administrator password and confirm it.
Step 5: Select Yes if you want to remove the database files.
Step 6: Select Yes if you want to move existing LDAP files.

Create a file named `base.ldif` using your preferred text editor. This file defines the base organizational units for your LDAP directory.

```
nano base.ldif
```

Add the following content to the file:

```
dn: ou=People,dc=example,dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=example,dc=com
objectClass: organizationalUnit
ou: Groups
```

Use the `ldapadd` command to add entries to the LDAP directory.

```
ldapadd -x -D cn=admin,dc=example,dc=com -W -f base.ldif
```

You will be prompted to enter the LDAP administrator's password.

Create a file named `account.ldif` to define user entries.

```
nano account.ldif
```

Add the following content to the file:

```
dn: uid=user1,ou=People,dc=example,dc=com
objectClass: inetOrgPerson
uid: user1
cn: User 1
sn: 1
mail: user1@example.com
userPassword: secret

dn: uid=user2,ou=People,dc=example,dc=com
objectClass: inetOrgPerson
uid: user2
cn: User 2
sn: 2
mail: user2@example.com
userPassword: secret
```

Use the `ldapadd` command to add entries to the LDAP directory.

```
ldapadd -x -D cn=admin,dc=example,dc=com -W -f account.ldif
```

Create a file named `group.ldif` to define group entries.

```
nano group.ldif
```

Add the following content to the file:

```
dn: cn=group1,ou=Groups,dc=example,dc=com
objectClass: groupOfNames
member: uid=user1,ou=People,dc=example,dc=com

dn: cn=group2,ou=Groups,dc=example,dc=com
objectClass: groupOfNames
member: uid=user2,ou=People,dc=example,dc=com
```

Use the `ldapadd` command to add entries to the LDAP directory.

```
ldapadd -x -D cn=admin,dc=example,dc=com -W -f group.ldif
```

You can use the `ldapsearch` command to test the LDAP connection and perform queries.

Here's how you can test:

```
ldapsearch -x -LLL -H ldap://localhost -b dc=example,dc=com
```

This command queries the LDAP server for all entries under the base DN. Replace `localhost` with your LDAP server's hostname or IP address.

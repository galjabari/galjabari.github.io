---
title: "Configure Mail server with LDAP authentication"
description: "A step-by-step guide on how to integrate mail server with the LDAP directory for user authentication on Ubuntu 20.04/22.04"
---

# Configure Mail server with LDAP authentication

Before integrating the mail server with an LDAP directory for user authentication, you need to complete the following guides:
[Install and configure LDAP Server on Ubuntu](install-ldap-server.md)
[Install and configure Mail Server on Ubuntu](install-mail-server.md)

Next, create a system user on the mail server to host virtual mail accounts.

```
sudo useradd -u 5000 -s /usr/sbin/nologin -d /var/mail vmail
```

Set permissions for virtual mail directories.

```
sudo chown -R vmail:vmail /var/mail
```

## Configure Postfix with LDAP

Install LDAP module for Postfix.

```
sudo apt install postfix-ldap -y
```

Edit the Postfix main configuration file.

```
sudo nano /etc/postfix/main.cf
```

Add or update the following lines to configure Postfix with LDAP.

```
virtual_mailbox_base = /var/mail
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000
virtual_mailbox_domains = example.com
virtual_mailbox_maps = ldap:/etc/postfix/ldap-mailboxes.cf
```

Make sure to remove the following line by commenting it out to deliver emails for virtual mail accounts:

```
#mydestination = example.com, localhost
```

Create the LDAP configuration file for mail account lookup.

```
sudo nano /etc/postfix/ldap-mailboxes.cf
```

Add the following lines:

```
server_host = localhost
server_port = 389
version = 3
bind = yes
bind_dn = cn=admin,dc=example,dc=com
bind_pw = secret
search_base = dc=example,dc=com
query_filter = (&(objectClass=inetOrgPerson)(mail=%s))
result_attribute = mail
result_format = %d/%u/
```

Replace the LDAP server details such as base DN, admin credentials, and hostname with your actual LDAP server information.

Restart the Postfix service to apply the changes.

```
sudo systemctl restart postfix.service
```

## Configure Dovecot with LDAP

Install LDAP module for Dovecot.

```
sudo apt install dovecot-ldap -y
```

Edit the Dovecot authentication configuration file:

```
sudo nano /etc/dovecot/conf.d/10-auth.conf
```

Ensure the following line are present and uncommented:

```
!include auth-ldap.conf.ext
```

To use only LDAP authentication, you may need to comment out the following line:

```
#!include auth-system.conf.ext
```

Edit the LDAP configuration for Dovecot:

```
sudo nano /etc/dovecot/dovecot-ldap.conf.ext
```

Add the following LDAP settings:

```
hosts = localhost
dn = cn=admin,dc=example,dc=com
dnpass = secret
auth_bind = yes
ldap_version = 3
base = dc=example,dc=com
user_filter = (&(objectClass=inetOrgPerson)(mail=%u))
pass_attrs = userPassword=password
pass_filter = (&(objectClass=inetOrgPerson)(mail=%u))
```

Replace the LDAP server details such as base DN, admin credentials, and hostname with your actual LDAP server information.

Edit the Dovecot mail configuration file:

```
sudo nano /etc/dovecot/conf.d/10-mail.conf
```

Add or modify the following lines:

```
mail_location = maildir:/var/mail/%d/%n
mail_uid = 5000
mail_gid = 5000
```

Restart the Dovecot service to apply the changes.

```
sudo systemctl restart dovecot.service
```

Try logging in via an email client to ensure authentication is working through LDAP. Test your mail server by sending a test email and checking if the email is delivered correctly.

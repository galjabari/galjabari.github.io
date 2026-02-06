---
title: "Configure Mail Server with Active Directory"
description: "A step-by-step guide on how to integrate a mail server on Ubuntu 20.04/22.04 with Active Directory for LDAP authentication."
---

# Configure Mail Server with Active Directory

Before integrating the mail server with Active Directory for LDAP authentication, you need to have a working mail server and Active Directory Domain Controller.

You can follow this guide to set up the mail server: [Install and configure Mail Server on Ubuntu](install-mail-server.md).

To set up the domain controller on Windows Server:
- Rename the server to `dc.example.com`.
- Install AD DS role on the server.
- Promote the server to a domain controller for `example.com`.
- Create AD Users for mail accounts (e.g. `admin@example.com`).

Next, verify that the mail server can access the domain controller over LDAP.

```
ldapsearch -H ldap://dc.example.com -x -D admin@example.com -W -b "DC=example,DC=com"
```

Create a system user on the mail server to host virtual mail accounts.

```
sudo useradd -u 5000 -s /usr/sbin/nologin -d /var/mail vmail
```

Set permissions for virtual mail directories.

```
sudo chown -R vmail:vmail /var/mail
```

## Configure Postfix with Active Directory

Install the LDAP module for Postfix.

```
sudo apt install postfix-ldap -y
```

Edit the Postfix main configuration file.

```
sudo nano /etc/postfix/main.cf
```

Add or update the following lines to configure Postfix with LDAP. Replace `example.com` with your actual Active Directory domain name.

```
virtual_mailbox_base = /var/mail
virtual_uid_maps = static:5000
virtual_gid_maps = static:5000
virtual_mailbox_domains = example.com
virtual_mailbox_maps = ldap:/etc/postfix/ad-mailboxes.cf
```

Make sure to remove the following line by commenting it out to deliver emails for virtual mail accounts:

```
#mydestination = example.com, localhost
```

Create the LDAP configuration file for mail account lookup.

```
sudo nano /etc/postfix/ad-mailboxes.cf
```

Add the following lines. Make sure to replace the server host, bind DN, password, and search base with your Active Directory details.

```
server_host = dc.example.com
server_port = 389
version = 3
bind = yes
bind_dn = admin@example.com
bind_pw = secret
search_base = CN=Users,DC=example,DC=com
query_filter = (&(objectClass=user)(userPrincipalName=%s))
result_attribute = userPrincipalName
result_format = %d/%u/
```

Restart the Postfix service to apply the changes.

```
sudo systemctl restart postfix.service
```

## Configure Dovecot with Active Directory

Install the LDAP module for Dovecot.

```
sudo apt install dovecot-ldap -y
```

Edit the Dovecot authentication configuration file:

```
sudo nano /etc/dovecot/conf.d/10-auth.conf
```

Ensure the following line is present and uncommented:

```
!include auth-ldap.conf.ext
```

To use only LDAP authentication, you may need to comment out the following line:

```
#!include auth-system.conf.ext
```

Edit the LDAP configuration for Dovecot.

```
sudo nano /etc/dovecot/dovecot-ldap.conf.ext
```

Update the configuration with your Active Directory settings:

```
hosts = dc.example.com
dn = admin@example.com
dnpass = secret
auth_bind = yes
ldap_version = 3
base = CN=Users,DC=example,DC=com
scope = subtree
user_filter = (&(objectClass=user)(userPrincipalName=%u))
pass_filter = (&(objectClass=user)(userPrincipalName=%u))
pass_attrs = userPassword=password
```

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

After configuration, you should be able to authenticate using Active Directory user credentials. Test your mail server by sending a test email and checking if the email is delivered correctly to an AD user's mailbox.

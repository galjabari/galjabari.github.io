---
layout: default
title: "Install and configure Mail Server on Ubuntu"
---

# Install and configure Mail Server on Ubuntu

Before setting up a mail server on Ubuntu, you need to complete the following guide:
- [Install and configure an authoritative DNS Server on Ubuntu](install-dns-server.md)

Next, edit the DNS zone file.

```bash
sudo nano /etc/bind/db.example.com
```

Add the following lines under the existing records:

```
@       IN      MX 10   mail.example.com.
mail    IN      A       192.168.1.10
smtp    IN      CNAME   mail.example.com.
imap    IN      CNAME   mail.example.com.
```

Replace `mail.example.com`  and `192.168.1.10` with your mail server's hostname and IP address.

After making changes, restart the BIND service to apply the configuration.

```bash
sudo systemctl restart bind9.service
```

Verify that BIND is running without errors.

```bash
sudo systemctl status bind9.service
```

Finally, test DNS resolution to list MX records for your domain:

```bash
dig MX example.com
```

## Install and configure SMTP Server

First, update package lists and install Postfix which functions as an SMTP server.

```bash
sudo apt update
sudo apt install postfix -y
```

During installation, you will be prompted to configure Postfix. Choose "Internet Site" as the mail configuration type and set the system mail name "example.com".

To reconfigure Postfix, run the following command:

```bash
sudo dpkg-reconfigure postfix
```

Step 1: Select Internet Site as the mail configuration type.
Step 2: Enter your mail domain name such as `example.com`.
Step 3: Enter your system administrator account such as `admin`.
Step 4: Enter `example.com, localhost` for other destinations.
Step 5: Select No to force synchronous updates.
Step 6: Enter `127.0.0.0/8 [::1]/128` for local networks.
Step 7: Enter `0` for mailbox size limit (no limit).
Step 8: Enter `+` for local address extension character.
Step 9: Enter `all` to use both IPv4 and IPv6 addresses.

Set the hostname for your mail server using the following command:

```bash
sudo postconf -e 'myhostname = mail.example.com'
```

Set the mailbox format to `Maildir` using the following command:

```bash
sudo postconf -e 'home_mailbox = Maildir/'
```

Restart the Postfix service to apply the changes.

```bash
sudo systemctl restart postfix.service
```

Check the status of the Postfix service to ensure it restarted without errors.

```bash
sudo systemctl status postfix.service
```

## Configure SMTP Authentication

First, install Dovecot SASL for authenticating users when they send emails through the SMTP server.

```bash
sudo apt install dovecot-core -y
```

Next, edit the Dovecot master configuration file.

```bash
sudo nano /etc/dovecot/conf.d/10-master.conf
```

Add or update the following lines to set up the authentication socket for Postfix:

```
# Postfix smtp-auth
unix_listener /var/spool/postfix/private/auth {
  mode = 0660
  user = postfix
  group = postfix
}
```

Edit the Postfix main configuration file.

```bash
sudo nano /etc/postfix/main.cf
```

Add or update the following lines to enable and configure SMTP authentication using Dovecot:

```
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination
```

Restart Dovecot and Postfix to apply the new configurations:

```bash
sudo systemctl restart dovecot.service
sudo systemctl restart postfix.service
```

To test the SMTP server, you can use the `telnet` command.

```bash
telnet mail.example.com 25
```

After connecting, you can issue the following command:

```
ehlo mail.example.com
```

Exit the connection by pressing Ctrl + ] and Type quit.

## Install and configure IMAP/POP3 Server

First, install Dovecot IMAP and POP3 server.

```bash
sudo apt install dovecot-imapd dovecot-pop3d -y
```

Edit the mail configuration file.

```bash
sudo nano /etc/dovecot/conf.d/10-mail.conf
```

Set the mail storage location using `Maildir` format:

```
mail_location = maildir:~/Maildir
```

Edit the authentication configuration file.

```bash
sudo nano /etc/dovecot/conf.d/10-auth.conf
```

Uncomment and modify the following lines:

```
disable_plaintext_auth = no
auth_mechanisms = plain login
```

Restart the Dovecot service to apply the changes.

```bash
sudo systemctl restart dovecot.service
```

Check the status of the Dovecot service to ensure it restarted without errors.

```bash
sudo systemctl status dovecot.service
```

You can test the IMAP server using `telnet` command.

```bash
telnet mail.example.com 143
```

Similarly, you can test the POP3 server.

```bash
telnet mail.example.com 110
```

## Configure Email client

Each email account corresponds to a system user on the mail server. Create users using the `adduser` command:

```bash
sudo adduser user1
```

During this process, you will be prompted to set a password and fill in additional information for each user.

To test sending and receiving emails using the mail server, you can configure an email client such as Thunderbird.

To install Thunderbird on Ubuntu, you can use the following command:

```bash
sudo apt-get install thunderbird -y
```

Configure the email client to connect to the mail server's hostname. Use the full email address as the username (such as `user1@example.com`) and the password set during user creation.

To monitor logs related to email services in real time, you can use the following command:

```bash
tail -f /var/log/mail.log
```

Press Ctrl + C to stop the `tail` command and restore the terminal.

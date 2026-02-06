---
title: "Install and configure Webmail client on Ubuntu"
description: "A step-by-step guide on how to install and configure Roundcube webmail client on Ubuntu 20.04/22.04"
---

# Install and configure Webmail client on Ubuntu

This guide assumes that you have an existing mail server with the hostname `mail.example.com` and you need to deploy a webmail client for users to access the mail server using a web browser.

First, install the required packages on your server to deploy Roundcube webmail using the following command:

```
sudo apt-get install apache2 mariadb-server roundcube -y
```

Next, you need to configure Apache web server to enable access to Roundcube:

```
sudo nano /etc/apache2/conf-enabled/roundcube.conf
```

Add or uncomment the following line in the file:

```
Alias /roundcube /var/lib/roundcube/public_html
```

Restart Apache to apply the changes:

```
sudo systemctl restart apache2.service
```

Now, edit the Roundcube configuration file:

```
sudo nano /etc/roundcube/config.inc.php
```

Update the following lines in the file:

```
$config['default_host'] = 'mail.example.com';
$config['smtp_server'] = 'mail.example.com';
$config['smtp_port'] = 25;
```

To access Roundcube webmail, open a web browser and enter your server's hostname or IP address followed by `/roundcube`, such as: `http://webmail.example.com/roundcube`.

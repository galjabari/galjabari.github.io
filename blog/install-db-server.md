---
layout: default
title: "Install and manage a Database Server on Ubuntu"
---

# Install and manage a Database Server on Ubuntu

First, update package lists to ensure you have the latest versions available:

```bash
sudo apt update
```

You can install MariaDB server using the following command:

```bash
sudo apt install mariadb-server -y
```

Once the installation is complete, the MariaDB server should be started automatically. You can check MariaDB service status by typing:

```bash
sudo systemctl status mariadb.service
```

Log in to the MariaDB server:

```bash
sudo mysql -u root -p
```

Press Enter to access the MariaDB server without a password. Type `exit` to quit MariaDB Shell.

After installing MariaDB, it's recommended to run the following script to secure the installation:

```bash
sudo mysql_secure_installation
```

Follow the prompts to set up a root password, remove anonymous users, disallow remote root login, and remove the test database.

To manage MariaDB using a web browser, you can use phpMyAdmin tool. To install phpMyAdmin on Ubuntu run the following command:

```bash
sudo apt install phpmyadmin -y
```

During the installation process, you will be prompted to choose the web server that should be automatically configured to run phpMyAdmin. Select `apache2` using the space bar, then press Enter to continue.

After selecting the web server, you'll be asked whether to configure the database for phpMyAdmin. Choose 'Yes' and proceed.

To access phpMyAdmin, navigate to `http://localhost/phpmyadmin` using a web browser on your database server. Replace `localhost` with your database server's hostname or IP address to access phpMyAdmin on your machine.

Log in with MariaDB username and password to manage your database.

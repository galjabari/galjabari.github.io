---
layout: default
title: "Configure FreeRADIUS with SQL for AAA"
---

# Configure FreeRADIUS with SQL for AAA

Before configuring FreeRADIUS to use SQL database as the backend for authentication, authorization, and accounting (AAA), you need to complete the following guides:
[Install and manage a Database Server on Ubuntu](install-db-server.md)
[Install and configure RADIUS Server on Ubuntu](install-radius-server.md)

First, install the SQL module for FreeRADIUS:

```
sudo apt-get install freeradius-mysql -y
```

## Configure a database server

Log in to the database server:

```
sudo mysql -u root -p
```

When prompted enter the `root` password to create the RADIUS database and user:

```sql
CREATE DATABASE radius;
GRANT ALL ON radius.* TO radius@localhost IDENTIFIED BY "radpass";
exit
```

Import the RADIUS database schema using the following command:

```
sudo mysql -u root -p radius < /etc/freeradius/3.0/mods-config/sql/main/mysql/schema.sql
```

Edit the `default` site configuration file and enable `sql` in the `authorize` and `accounting` sections:

```
nano /etc/freeradius/3.0/sites-available/default
```

```
authorize {
    ...
    sql
    ...
}

accounting {
    ...
    sql
    ...
}
```

Similarly, edit `inner-tunnel` configuration file and enable `sql` in the `authorize` and `accounting` sections:

```
nano /etc/freeradius/3.0/sites-available/inner-tunnel
```

Edit the SQL module configuration file:

```
nano /etc/freeradius/3.0/mods-available/sql
```

Modify the following lines to match your database configuration:

```
driver = "rlm_sql_mysql"
server = "localhost"
port = 3306
login = "radius"
password = "radpass"
radius_db = "radius"
read_clients = yes
```

Replace `localhost` with your database server's hostname or IP address. Ensure that TLS encryption is disabled in `mysql` section by commenting out the entire `tls` block.

Create a symbolic link to enable the SQL module:

```
ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql
```

Edit the EAP configuration file to send reply attributes with PEAP authentication method:

```
nano /etc/freeradius/3.0/mods-available/eap
```

Look for `peap` section, ensure to modify the following line:

```
peap {
    ...
    use_tunneled_reply = yes
    ...
}
```

To apply the changes, restart the FreeRADIUS service:

```
systemctl restart freeradius.service
```

To verify your configuration, log in to the database server:

```
mysql -u radius -p
```

When prompted enter the password and add a new user into the database:

```
USE radius;
INSERT INTO radcheck (username, attribute, op, value) VALUES ('user1', 'Cleartext-Password', ':=', 'secret');
exit
```

Finally, test the configuration using the `radtest` command:

```
radtest user1 secret localhost 0 testing123
```

You should see an `Access-Accept` message if your RADIUS server is configured correctly.

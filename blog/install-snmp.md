---
title: "Install and configure SNMP on Ubuntu"
---

# Install and configure SNMP on Ubuntu

Simple Network Management Protocol (SNMP) is used for monitoring network devices and servers.

This guide explains how to install and configure SNMP on Ubuntu.

First, update your package list and install the SNMP daemon and SNMP tools.

```
sudo apt update
sudo apt install snmp snmpd -y
```

Next, you need to configure the SNMP daemon.

```
sudo nano /etc/snmp/snmpd.conf
```

Make the following changes to the file.

```
sysLocation  Server Room
sysContact   admin@example.com
agentAddress 0.0.0.0,[::]
rocommunity  public default
```

This configuration sets the system location, contact information, the agent's listening address, and a read-only community string. It is highly recommended to change 'public' to a more secure string to enhance security.

Restart the SNMP daemon for the changes to take effect.

```
sudo systemctl restart snmpd
```

Then, check its status and enable it to start on boot.

```
sudo systemctl status snmpd
sudo systemctl enable snmpd
```

You can test the SNMP configuration using the `snmpwalk` command.

```
snmpwalk -v2c -c public localhost
```

Here are some examples using common Object Identifiers (OIDs):

```
# Get system uptime
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1.3
# Get system contact
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1.4
# Get system location
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1.6
```

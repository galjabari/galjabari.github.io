---
layout: default
title: "Configure FreeRADIUS with SQL for dynamic ACL assignment"
---

# Configure FreeRADIUS with SQL for dynamic ACL assignment

This guide assumes you have already configured [FreeRADIUS with SQL backend](configure-freeradius-sql.md) and you need to assign access control lists (ACLs) for users in the SQL database based on group membership.

## Configure RADIUS server

First, connect to SQL database using your preferred SQL client (like `mysql` or phpMyAdmin).

To add users to RADIUS database, insert user credentials into the `radcheck` table.

```
INSERT INTO radcheck (username, attribute, op, value) VALUES ('user1', 'Cleartext-Password', ':=', 'secret');
INSERT INTO radcheck (username, attribute, op, value) VALUES ('user2', 'Cleartext-Password', ':=', 'secret');
```

To assign users to groups, insert group members into the `radusergroup` table.

```
INSERT INTO radusergroup (username, groupname, priority) VALUES ('user1', 'group1', 1);
INSERT INTO radusergroup (username, groupname, priority) VALUES ('user2', 'group2', 1);
```

You need to define each RADIUS client that will communicate with the RADIUS server to authenticate users.

To add a RADIUS client, insert the client's details into the `nas` table.

```
INSERT INTO nas (nasname, shortname, type, secret) VALUES ('192.168.1.2', 'cisco-switch', 'other', 'pass@123');
```

Each RADIUS client (NAS) has its own extended attributes known as vendor-specific attributes (VSAs). For example, `cisco-avpair` attribute is used to apply specific policies and configurations on Cisco devices.

To define an ACL for each group, insert `cisco-avpair` RADIUS attributes into the `radgroupreply` table.

```
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group1', 'cisco-avpair', '=', 'ip:inacl#1=permit ip any any');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#1=permit udp any any eq 53');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#2=permit tcp any any eq 53');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#3=permit udp any any eq 67');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#4=permit udp any any eq 68');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#5=permit tcp any any eq 80');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#6=permit tcp any any eq 443');
INSERT INTO radgroupreply (groupname, attribute, op, value) VALUES ('group2', 'cisco-avpair', '=', 'ip:inacl#7=deny ip any any');
```

In this example, users belong to `group1` can access all services and users belong to `group2` can access only DNS, DHCP, and web services.

Finally, use `radtest` command to ensure that users are being authenticated and assigned the correct ACLs.

```
radtest user2 secret localhost 0 testing123
```

## Configure a Cisco switch

You can use the RADIUS server to configure a Cisco switch to dynamically assign ACLs to users based on their groups.

For example, to configure a Cisco switch (IOS 15.x) to use the RADIUS server, execute the following commands:

```
Switch>en
Switch#conf t
Switch(config)#interface vlan 1
Switch(config-if)#ip address 192.168.1.2 255.255.255.0
Switch(config-if)#no shut
Switch(config-if)#exit
Switch(config)#aaa new-model
Switch(config)#radius server RADIUS-SERVER
Switch(config-radius-server)#address ipv4 192.168.1.10 auth-port 1812 acct-port 1813
Switch(config-radius-server)#key pass@123
Switch(config-radius-server)#exit
Switch(config)#aaa authentication dot1x default group radius
Switch(config)#aaa authorization network default group radius
Switch(config)#dot1x system-auth-control
Switch(config)#interface gi0/1
Switch(config-if)#switchport mode access
Switch(config-if)#authentication port-control auto
Switch(config-if)#dot1x pae authenticator
Switch(config-if)#exit
Switch(config)#exit
```

Replace `192.168.1.10` with the IP address of your RADIUS server and `pass@123` with your shared secret key.

After configuring Cisco switch, connect a client to the configured interface and ensure the ACL is enforced on the interface. Check the interface status and ACL enforcement by executing the following commands:

```
Switch#show authentication brief
Switch#show authentication sessions interface gi0/1 details
Switch#show access-lists
```

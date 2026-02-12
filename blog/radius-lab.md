---
layout: default
title: "Deploy a RADIUS Server with Containerlab"
---

# Deploy a RADIUS Server with Containerlab

This guide walks you through setting up a RADIUS server with Containerlab and configuring AAA on an Arista cEOS switch to authenticate users using RADIUS.

First, create the directory structure for the RADIUS server configuration files.

```bash
mkdir -p raddb/mods-config/files
```

Create the `raddb/clients.conf` file and add the following content to define the RADIUS client (the Arista switch).

```
client switch {
    ipaddr     = 192.168.10.1
    secret     = clab
}
```

This configuration allows the switch to communicate with the RADIUS server using the shared secret `clab`.

Create the `raddb/mods-config/files/authorize` file and add the following content to define user credentials.

```
clab  Cleartext-Password := "clab"
    Arista-AVPair := "shell:roles=network-admin"
```

This configuration allows the user `clab` to log in with the password `clab` and grants them the `network-admin` role on the Arista switch.

Next, define the lab topology in a YAML file. The lab consists of an Arista cEOS switch and a RADIUS server.

Create a file named `radius.clab.yml` and add the following content:

```yaml
name: radius
topology:
  nodes:
    switch:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    server:
      kind: linux
      image: freeradius/freeradius-server:latest-alpine
      cmd: -X
      binds:
        - ./raddb/clients.conf:/etc/raddb/clients.conf
        - ./raddb/mods-config/files/authorize:/etc/raddb/mods-config/files/authorize
      exec:
        - ip addr add 192.168.10.10/24 dev eth1
  links:
    - endpoints: ["switch:eth1", "server:eth1"]
```

Create the switch configuration file named `switch.cfg`:

```
!
enable
configure terminal
!
username admin privilege 15 secret admin
!
interface Ethernet1
   no switchport
   ip address 192.168.10.1/24
   no shutdown
!
radius-server host 192.168.10.10 key clab
!
aaa authentication login default group radius local
aaa authorization exec default group radius local
!
end
```

This configuration sets up the switch to use the RADIUS server at `192.168.10.10` with the shared secret `clab`. It also configures AAA to authenticate users via RADIUS and fall back to local authentication if RADIUS is unavailable.

Deploy the lab using Containerlab:

```bash
clab deploy -t radius.clab.yml
```

To verify the RADIUS authentication, connect to the Arista switch using SSH:

```bash
ssh clab@clab-radius-switch
```

Enter the password `clab` when prompted. You should be able to log in and see the switch prompt.

To view the RADIUS server logs, check the output of the RADIUS server container:

```bash
docker logs clab-radius-server
```

This will show you the authentication requests and responses.

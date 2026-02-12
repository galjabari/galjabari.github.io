---
layout: default
title: "Deploy a DNS Server with Containerlab"
---

# Deploy a DNS Server with Containerlab

This guide walks you through setting up a DNS server with Containerlab. The lab includes a DNS server, a web server, and a client for testing DNS resolution.

First, create the directory structure for the BIND DNS server configuration files.

```bash
mkdir -p bind/zones
```

Create the `bind/named.conf` file and add the following content to configure the DNS server:

```
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-recursion { none; };
    allow-transfer { none; };
    allow-update { none; };
};
zone "example.com." {
    type primary;
    file "/var/lib/bind/db.example.com";
    notify explicit;
};
```

This configuration defines a primary zone for `example.com`.

Create the `bind/zones/db.example.com` file and add the following content to define the DNS records for the `example.com` zone:

```
$TTL 86400
@     IN  SOA     example.com. admin.example.com. (
                  2025071101 ; Serial
                  3600       ; Refresh
                  1800       ; Retry
                  604800     ; Expire
                  86400 )    ; Negative Cache TTL
@     IN  NS      ns1.example.com.
ns1   IN  A       192.168.10.10
@     IN  A       192.168.10.11
www   IN  CNAME   example.com.
```

Next, define the lab topology in a YAML file. The lab consists of an Arista cEOS switch, a DNS server, a web server, and a client.

Create a file named `dns.clab.yml` and add the following content:

```yaml
name: dns
topology:
  nodes:
    switch:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: switch.cfg
    server:
      kind: linux
      image: internetsystemsconsortium/bind9:9.20
      binds:
        - ./bind/named.conf:/etc/bind/named.conf
        - ./bind/zones:/var/lib/bind    
      ports:
        - 5353:53
        - 5353:53/udp   
      exec:
        - ip addr add 192.168.10.10/24 dev eth1
    web:
      kind: linux
      image: nginx:alpine
      exec:
        - ip addr add 192.168.10.11/24 dev eth1
    client:
      kind: linux
      image: alpine:latest     
      exec:
        - ip addr add 192.168.10.100/24 dev eth1
        - sh -c 'echo "nameserver 192.168.10.10" > /etc/resolv.conf'
  links:
    - endpoints: ["switch:eth1", "server:eth1"]
    - endpoints: ["switch:eth2", "web:eth1"]
    - endpoints: ["switch:eth3", "client:eth1"]
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
   switchport
!
interface Ethernet2
   switchport
!
interface Ethernet3
   switchport
!
end
```

Deploy the lab using Containerlab:

```bash
clab deploy -t dns.clab.yml
```

To verify DNS resolution, connect to the client container and attempt to ping the web server using its DNS name:

```bash
docker exec -it clab-dns-client sh
ping www.example.com
```

Test web server access:

```sh
wget -O- http://www.example.com
```

This should return the Nginx welcome page.

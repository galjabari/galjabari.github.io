---
title: "Deploy an Authoritative DNS Server with Docker"
description: "A step-by-step guide on how to deploy an authoritative DNS server with Docker."
---

# Deploy an Authoritative DNS Server with Docker

This guide will walk you through deploying an authoritative DNS server using Docker and BIND 9. We will create a docker network and set up a DNS server, a web server, and a client to test the configuration.

First, create a directory for the configuration files.

```
mkdir bind
```

Create the main BIND configuration file.

```
nano bind/named.conf
```

Add the following content:

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
    file "/etc/bind/db.example.com";
    notify explicit;
};
```

Create the zone file for your domain. Replace `example.com` with your actual domain.

```
nano bind/db.example.com
```

Add the following content:

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

Create the `docker-compose.yml` file to define Docker containers.

```
nano docker-compose.yml
```

Add the following content:

```
networks:
  lab_network:
    driver: bridge
    ipam:
      config:
        - subnet: 192.168.10.0/24
          gateway: 192.168.10.1
services:
  dns-server:
    image: internetsystemsconsortium/bind9:9.20
    container_name: bind9
    restart: always
    ports:
      - "5353:53/tcp"
      - "5353:53/udp"
    networks:
      lab_network:
        ipv4_address: 192.168.10.10
    dns:
      - 192.168.10.10
    volumes:
      - ./bind:/etc/bind
  web-server:
    image: nginx
    container_name: nginx
    networks:
      lab_network:
        ipv4_address: 192.168.10.11
    dns:
      - 192.168.10.10
  client:
    image: alpine
    container_name: alpine
    networks:
      lab_network: {}
    dns:
      - 192.168.10.10
    tty: true
    stdin_open: true
```

Deploy the services using Docker Compose.

```
docker compose up -d
```

Access the client container to test DNS resolution.

```
docker exec -it alpine sh
```

Test DNS resolution for `example.com`.

```
nslookup example.com
```

This should return the IP address of `example.com`.

Test web server access.

```
wget -O- http://example.com
```

This should return the Nginx welcome page.

To clean up everything after you are done, use:

```
docker compose down
```

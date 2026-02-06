---
layout: default
title: "Deploy a Mail Server with Docker"
---

# Deploy a Mail Server with Docker

This guide will walk you through deploying a mail server using Docker, featuring Roundcube webmail and a BIND DNS server.

First, create directories for the BIND, mailserver, and Roundcube containers.

```
mkdir bind mail roundcube
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

Create the zone file for `example.com`. This includes the MX record for the mail server.

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
@     IN  MX 10   mail.example.com.
mail  IN  A       192.168.10.12
```

Create the `docker-compose.yml` file to define the Docker containers.

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
  mail-server:
    image: ghcr.io/docker-mailserver/docker-mailserver
    container_name: mailserver
    hostname: mail.example.com
    ports:
      - "25:25"
      - "143:143"
      - "465:465"
      - "587:587"
      - "993:993"
    networks:
      lab_network:
        ipv4_address: 192.168.10.12
    dns:
      - 192.168.10.10
    volumes:
      - ./mail/data/:/var/mail/
      - ./mail/logs/:/var/log/mail/
      - ./mail/state/:/var/mail-state/
      - ./mail/:/tmp/docker-mailserver/
      - /etc/localtime:/etc/localtime:ro
  webmail:
    image: roundcube/roundcubemail
    container_name: roundcube
    ports:
      - "8080:80"
    networks:
      lab_network: {}
    dns:
      - 192.168.10.10
    volumes:
      - ./roundcube:/var/www/html
    environment:
      - ROUNDCUBEMAIL_DEFAULT_HOST=mail.example.com
      - ROUNDCUBEMAIL_DEFAULT_PORT=143
      - ROUNDCUBEMAIL_SMTP_SERVER=mail.example.com
      - ROUNDCUBEMAIL_SMTP_PORT=587
      - ROUNDCUBEMAIL_USERNAME_DOMAIN=example.com
```

Deploy the services using Docker Compose.

```
docker compose up -d
```

Before using the mail server, you need to create a user account. Use the following command to create an email account for `user1@example.com` with the password `pass@123`.

```
docker exec -it mailserver setup email add user1@example.com pass@123
```

You can now access the Roundcube webmail client by navigating to `http://localhost:8080` in your web browser. For remote access, use your docker host's IP. Log in with the username `user1@example.com` and the password `pass@123`.

To clean up everything after you are done, use:

```
docker compose down
```

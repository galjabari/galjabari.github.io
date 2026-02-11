---
layout: default
title: "Enable DNSSEC with BIND on Ubuntu"
---

# Enable DNSSEC with BIND on Ubuntu

DNSSEC is a security extension for DNS that adds a layer of authentication to prevent DNS spoofing and cache poisoning attacks.

This guide assumes you have a primary DNS server configured as in the [Install and configure an authoritative DNS Server on Ubuntu](install-dns-server.md) guide, and you need to enable DNSSEC for your domain.

First, create a directory to store the DNSSEC keys:

```bash
sudo mkdir -p /etc/bind/keys
cd /etc/bind/keys
```

Generate the Zone Signing Key (ZSK) for your domain. Replace `example.com` with your actual domain name:

```bash
sudo dnssec-keygen -a RSASHA256 -b 2048 -n ZONE example.com
```

Generate the Key Signing Key (KSK) for your domain:

```bash
sudo dnssec-keygen -a RSASHA256 -b 2048 -n ZONE -f KSK example.com
```

Edit the zone file for your domain:

```bash
sudo nano /etc/bind/db.example.com
```

Include the generated keys at the bottom of the zone file. Replace the placeholders with the actual key IDs from the generated files in the keys directory:

```
$INCLUDE "/etc/bind/keys/Kexample.com.+008+<ZSK_ID>.key"
$INCLUDE "/etc/bind/keys/Kexample.com.+008+<KSK_ID>.key"
```

Sign the zone file with the generated keys:

```bash
sudo dnssec-signzone -o example.com /etc/bind/db.example.com \
Kexample.com.+008+<ZSK_ID> Kexample.com.+008+<KSK_ID>
```

This command generates a signed zone file named `db.example.com.signed` in the same directory. Be sure to run it again whenever you make changes to the original zone file.

Edit the BIND configuration file to point to the signed zone file:

```bash
sudo nano /etc/bind/named.conf.local
```

Update the zone configuration:

```
zone "example.com" {
    type master;
    file "/etc/bind/db.example.com.signed";
};
```

Restart the BIND service to apply the changes:

```bash
sudo systemctl restart bind9.service
```

Check the status of the BIND service:

```bash
sudo systemctl status bind9.service
```

To verify DNSSEC is enabled, use the following command:

```bash
dig +dnssec +multi example.com @localhost
```

To submit your DNSSEC keys to your domain registrar, run the following command to display the Delegation Signer (DS) record:

```bash
cat /etc/bind/keys/dsset-example.com.
```

Whenever you update the KSK, you must also update the DS record with your domain registrar.

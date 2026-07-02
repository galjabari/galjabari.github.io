---
layout: default
title: "DNS Server on Windows Server"
categories: ["Windows Server Administration", "DNS Server"]
tags: ["Windows Server", "DNS", "PowerShell"]
---

# DNS Server on Windows Server

This lab covers the installation and configuration of a DNS server on Windows Server 2022, including managing forward and reverse lookup zones, and various DNS record types.

## 1. Install and Configure DNS Server Role

### Install role
To start, install the DNS server role and its associated management tools.
```powershell
Install-WindowsFeature -Name DNS -IncludeManagementTools
```

### Check service
Verify that the DNS service is running after installation.
```powershell
Get-Service -Name DNS
```

### Get all root servers
Root hints are essential for a DNS server to resolve names outside its configured zones. This command displays the current root hints.
```powershell
Get-DnsServerRootHint
```

### Configure forwarders
Forwarders are DNS servers to which your DNS server sends queries that it cannot resolve locally. It's common to use public DNS servers like Google's (8.8.8.8 and 8.8.4.4).
```powershell
Set-DnsServerForwarder -IPAddress "8.8.8.8", "8.8.4.4"
```

## 2. Manage Forward Lookup Zones and Records

### Create forward lookup zone (Primary)
A forward lookup zone maps hostnames to IP addresses. This command creates a primary zone for `example.com`.
```powershell
Add-DnsServerPrimaryZone -Name "example.com" -ZoneFile "example.com.dns" -DynamicUpdate None
```

### Create A record
An A record (Address record) maps a hostname to an IPv4 address. Here, we create an A record for the domain itself (`@`) and for `blog.example.com`.
```powershell
Add-DnsServerResourceRecordA -Name "@" -ZoneName "example.com" -IPv4Address "192.168.10.11"
Add-DnsServerResourceRecordA -Name "blog" -ZoneName "example.com" -IPv4Address "192.168.10.11"
```

### Create CNAME record
A CNAME record (Canonical Name record) creates an alias for an existing A record. This example creates `www.example.com` as an alias for `example.com`.
```powershell
Add-DnsServerResourceRecordCName -Name "www" -ZoneName "example.com" -HostNameAlias "example.com"
```

### Create MX record 
An MX record (Mail Exchange record) specifies the mail server responsible for accepting email messages on behalf of a domain. We also create an A record for the mail server.
```powershell
Add-DnsServerResourceRecordMX -Name "@" -ZoneName "example.com" -MailExchange "mail.example.com" -Preference 10
Add-DnsServerResourceRecordA -Name "mail" -ZoneName "example.com" -IPv4Address "192.168.10.12"
```

### Create TXT record 
A TXT record can hold arbitrary human-readable text and is often used for SPF (Sender Policy Framework) records to prevent email spoofing.
```powershell
Add-DnsServerResourceRecord -Name "@" -ZoneName "example.com" -TXT -DescriptiveText "v=spf1 mx -all"
```

### List all records
To view all DNS records within a specific zone, use `Get-DnsServerResourceRecord`.
```powershell
Get-DnsServerResourceRecord -ZoneName "example.com"
```

### Set DNS server to itself
For the DNS server to use itself for name resolution, configure its network adapter to point to its own IP address (or localhost).
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("127.0.0.1")
```

### Verify
Use `Resolve-DnsName` to test the resolution of various record types.
```powershell
Resolve-DnsName -Name example.com 
Resolve-DnsName -Name www.example.com 
Resolve-DnsName -Name example.com -Type MX 
Resolve-DnsName -Name example.com -Type TXT
```

### Remove record
To remove a specific DNS record, provide its `ZoneName`, `RRType`, `Name`, and `RecordData`.
```powershell
Remove-DnsServerResourceRecord -ZoneName "example.com" -RRType "A" -Name "blog" -RecordData "192.168.10.11" -Force
```

### Update NS record 
NS records (Name Server records) identify the authoritative DNS servers for a zone. Here, we remove the default NS record and add a new one pointing to `ns1.example.com`.
```powershell
Remove-DnsServerResourceRecord -ZoneName "example.com" -Name "@" -RRType "NS" -Force
Add-DnsServerResourceRecord -ZoneName "example.com" -NS -Name "@" -NameServer "ns1.example.com"
Add-DnsServerResourceRecordA -Name "ns1" -ZoneName "example.com" -IPv4Address "192.168.10.10"
Resolve-DnsName -Name example.com -Type NS
```

### Update SOA record
The SOA record (Start of Authority) contains administrative information about the zone. We clone the existing SOA record, update the `PrimaryServer` and `ResponsiblePerson`, and then set the new SOA record.
```powershell
$Old = Get-DnsServerResourceRecord -ZoneName "example.com" -RRType SOA
$New = $Old.Clone()
$New.RecordData.PrimaryServer = "ns1.example.com."
$New.RecordData.ResponsiblePerson = "admin.example.com."
Set-DnsServerResourceRecord -ZoneName "example.com" -OldInputObject $Old -NewInputObject $New
Resolve-DnsName -Name example.com -Type SOA
```

### Remove zone
To remove an entire DNS zone, use `Remove-DnsServerZone`.
```powershell
Remove-DnsServerZone -Name "example.com" -Force
```

## 3. Manage Reverse Lookup Zones and Records

### Create reverse lookup zone (Primary)
A reverse lookup zone maps IP addresses to hostnames. This is crucial for services that perform reverse DNS lookups, like mail servers.
```powershell
Add-DnsServerPrimaryZone -Name "10.168.192.in-addr.arpa" -ZoneFile "10.168.192.in-addr.arpa.dns" -DynamicUpdate None
```

### Create PTR record
A PTR record (Pointer record) is used in reverse lookup zones to map an IP address to a hostname.
```powershell
Add-DnsServerResourceRecordPtr -ZoneName "10.168.192.in-addr.arpa" -Name "12" -PtrDomainName "mail.example.com"
```

### Verify
Verify the PTR record resolution by querying the IP address.
```powershell
Resolve-DnsName -Name "192.168.10.12"
```

### Update NS record 
Similar to forward zones, update the NS record for the reverse lookup zone to point to the authoritative name server.
```powershell
Remove-DnsServerResourceRecord -ZoneName "10.168.192.in-addr.arpa" -Name "@" -RRType "NS" -Force
Add-DnsServerResourceRecord -ZoneName "10.168.192.in-addr.arpa" -NS -Name "@" -NameServer "ns1.example.com"
Resolve-DnsName -Name "10.168.192.in-addr.arpa" -Type NS
```

### Update SOA record
Update the SOA record for the reverse lookup zone with the correct primary server and responsible person.
```powershell
$Old = Get-DnsServerResourceRecord -ZoneName "10.168.192.in-addr.arpa" -RRType SOA
$New = $Old.Clone()
$New.RecordData.PrimaryServer = "ns1.example.com."
$New.RecordData.ResponsiblePerson = "admin.example.com."
Set-DnsServerResourceRecord -ZoneName "10.168.192.in-addr.arpa" -OldInputObject $Old -NewInputObject $New
Resolve-DnsName -Name "10.168.192.in-addr.arpa" -Type SOA
```
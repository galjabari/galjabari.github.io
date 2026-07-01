---
layout: default
title: "Networking Basics"
categories: ["Windows Server Administration", "Networking Basics"]
tags: ["Windows Server", "Networking", "PowerShell"]
---

# Networking Basics using PowerShell

This lab covers the fundamental networking commands in Windows Server 2022 using PowerShell.

## 1. Identify Network Adapters
To begin, we need to identify the network adapters present on the system. This command lists all physical and virtual network adapters.
```powershell
Get-NetAdapter
```

## 2. Verify Network Settings
After identifying the adapter, we can verify its current IP configuration, including IP address, subnet mask, and default gateway. Replace `"Ethernet0"` with your adapter's actual name if it's different.
```powershell
Get-NetIPConfiguration -InterfaceAlias "Ethernet0"
```

## 3. View IP Address
To specifically view the assigned IP address for a network adapter, use the following command:
```powershell
Get-NetIPAddress -InterfaceAlias "Ethernet0"
```

## 4. View DNS Servers
This command displays the DNS servers configured for a specific network adapter.
```powershell
Get-DnsClientServerAddress -InterfaceAlias "Ethernet0"
```

## 5. Test Connectivity
Finally, to test network connectivity to a remote host (e.g., Google's DNS server), use `Test-Connection`.
```powershell
Test-Connection -ComputerName 8.8.8.8
```
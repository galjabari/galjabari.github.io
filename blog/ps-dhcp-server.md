---
layout: default
title: "DHCP Server on Windows Server"
categories: ["Windows Server Administration", "DHCP Server"]
tags: ["Windows Server", "DHCP", "PowerShell"]
---

# DHCP Server on Windows Server

This lab provides a comprehensive guide to setting up and managing a DHCP server on Windows Server 2022 using PowerShell.

## 1. Install and Configure DHCP Server Role

### Install role
To begin, install the DHCP server role and its management tools using the `Install-WindowsFeature` cmdlet.
```powershell
Install-WindowsFeature DHCP -IncludeManagementTools
```

### Check service
After installation, verify that the DHCP Server service is running.
```powershell
Get-Service -Name DHCPServer
```

### Create security groups
Before creating scopes, it's good practice to create the necessary security groups for DHCP administration.
```powershell
Add-DhcpServerSecurityGroup
```

### Restart service
Sometimes, a restart of the DHCP service is required for changes to take effect.
```powershell
Restart-Service -Name DHCPServer
```

## 2. Create and Configure DHCP Scopes

### Create scope
A DHCP scope defines a range of IP addresses that the DHCP server can lease to clients. This example creates a scope named "Lab Scope" with a specified IP range, subnet mask, and lease duration.
```powershell
Add-DhcpServerV4Scope -Name "Lab Scope" -StartRange 192.168.10.100 -EndRange 192.168.10.200 -SubnetMask 255.255.255.0 -LeaseDuration 1.00:00:00
```

### Set options
DHCP options provide clients with additional configuration information, such as the default gateway (Option ID 3) and DNS servers (Option ID 6). You must specify the `ScopeId` to apply these options to a particular scope.
```powershell
# Set Router/Default Gateway option
Set-DhcpServerV4OptionValue -OptionId 3 -Value 192.168.10.2 -ScopeId 192.168.10.0
# Set DNS Servers option
Set-DhcpServerV4OptionValue -OptionId 6 -Value "192.168.10.10" -ScopeId 192.168.10.0 -Force
```

## 3. Manage DHCP Exclusions and Reservations

### Add exclusions
Exclusion ranges prevent the DHCP server from leasing specific IP addresses within a scope. This is useful for static assignments to servers or network devices.
```powershell
Add-DhcpServerv4ExclusionRange -ScopeId 192.168.10.0 -StartRange 192.168.10.100 -EndRange 192.168.10.130
```

### Create reservations
A reservation ensures that a specific device always receives the same IP address from the DHCP server based on its MAC address (Client ID).
```powershell
Add-DhcpServerv4Reservation -ScopeId 192.168.10.0 -IPAddress 192.168.10.150 -ClientId "00-1A-2B-3C-4D-5E" -Description "Printer"
```

### Remove reservations
To remove a reservation, specify the IP address of the reserved client.
```powershell
Remove-DhcpServerv4Reservation -IPAddress 192.168.10.150
```

## 4. Verify DHCP Configuration
These commands allow you to verify the DHCP scope configuration, statistics, and active leases.
```powershell
Get-DhcpServerV4Scope
Get-DhcpServerV4ScopeStatistics -ScopeId 192.168.10.0
Get-DhcpServerv4Lease -ScopeId 192.168.10.0
```

## 5. Remove DHCP Scope
If a DHCP scope is no longer needed, you can remove it using `Remove-DhcpServerv4Scope`. The `-Force` parameter bypasses the confirmation prompt.
```powershell
Remove-DhcpServerv4Scope -ScopeId 192.168.10.0 -Force
```
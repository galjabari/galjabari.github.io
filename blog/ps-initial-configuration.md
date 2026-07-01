---
layout: default
title: "Initial System Configuration"
categories: ["Windows Server Administration", "Initial System Configuration"]
tags: ["Windows Server", "Configuration", "PowerShell"]
---

# Initial Configuration of Windows Server

This lab guides you through the initial configuration of a Windows Server 2022 instance, covering network settings, computer naming, time zone, RDP, and Windows updates.

## 1. Configure IP Address Settings

### Set static IP address
To assign a static IP address to your network adapter, use the `New-NetIPAddress` cmdlet. Remember to replace `"Ethernet0"` with your actual adapter name, and adjust the IP address, prefix length, and default gateway as needed for your network.
```powershell
New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.10.10 -PrefixLength 24 -DefaultGateway 192.168.10.2
```

### Remove IP address
If you need to remove a previously configured static IP address, use `Remove-NetIPAddress`. The `-Confirm:$false` flag prevents a confirmation prompt.
```powershell
Remove-NetIPAddress -InterfaceAlias "Ethernet0" -Confirm:$false
```

### Remove default gateway
To remove the default gateway associated with a network interface, use `Remove-NetRoute`.
```powershell
Remove-NetRoute -InterfaceAlias "Ethernet0" -DestinationPrefix "0.0.0.0/0" -Confirm:$false
```

### Set dynamic IP address (DHCP)
To configure the network adapter to obtain an IP address automatically from a DHCP server, use `Set-NetIPInterface`.
```powershell
Set-NetIPInterface -InterfaceAlias "Ethernet0" -Dhcp Enabled
```

## 2. Configure DNS Servers

### Set DNS servers
To manually set specific DNS server addresses for your network adapter, use `Set-DnsClientServerAddress`. You can provide multiple DNS servers as a comma-separated list.
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses ("8.8.8.8","8.8.4.4")
```

### Reset to automatic DNS
To revert to automatically obtaining DNS server addresses (e.g., from DHCP), use the `-ResetServerAddresses` parameter.
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ResetServerAddresses
```

### Restart network adapter
If you make changes to network settings and want them to take effect immediately, or to troubleshoot connectivity, restarting the network adapter is often necessary.
```powershell 
Restart-NetAdapter -Name "Ethernet0"
```

## 3. System Identification and Time Zone

### Change computer name
It's crucial to give your server a descriptive name. This command renames the computer and requires a restart to apply the change.
```powershell
Rename-Computer -NewName "DC" -Restart
```

### Set system time zone
Proper time synchronization is important for many services. Set the appropriate time zone for your server.
```powershell
Set-TimeZone -Id "West Bank Standard Time"
```

## 4. Remote Desktop Protocol (RDP) Configuration

### Enable RDP
To enable Remote Desktop Protocol (RDP) access to your server, you need to modify a registry key and enable the firewall rule.
```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

### Disable RDP
To disable RDP access, set the registry key value back to 1 and disable the firewall rule.
```powershell
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 1
Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

## 5. Install Windows Updates

Keeping your server updated is vital for security and stability. This section demonstrates how to install updates using PowerShell.

First, set the PowerShell execution policy to allow scripts, then install the `PSWindowsUpdate` module, check for available updates, and finally install all of them with automatic reboot if necessary.
```powershell
# Set execution policy to allow scripts
Set-ExecutionPolicy RemoteSigned 
# Install PSWindowsUpdate module
Install-Module -Name PSWindowsUpdate
# Check for available updates
Get-WindowsUpdate
# Install all updates and reboot automatically if needed
Install-WindowsUpdate -AcceptAll -AutoReboot
```
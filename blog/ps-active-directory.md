---
layout: default
title: "Active Directory on Windows Server"
categories: ["Windows Server Administration", "Active Directory"]
tags: ["Windows Server", "Active Directory", "AD DS", "PowerShell"]
---

# Active Directory on Windows Server

This lab provides a step-by-step guide to installing and configuring Active Directory Domain Services (AD DS) on Windows Server 2022, including domain promotion, DHCP integration, joining client computers, and managing Organizational Units (OUs), groups, and users.

## 1. Install and Configure Active Directory Domain Services

### Install AD DS
Begin by installing the Active Directory Domain Services role and its management tools. After installation, import the `ADDSDeployment` module, which contains cmdlets for AD DS deployment, and then install a new Active Directory forest with the specified domain name and DNS integration.
```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
Install-ADDSForest -DomainName "lab.local" -InstallDns -Force
```

### Authorize DHCP server in AD
If you have a DHCP server in your network, it needs to be authorized in Active Directory to function correctly. This command authorizes the DHCP server using its DNS name and IP address.
```powershell
Add-DhcpServerInDC -DnsName "dc.lab.local" -IPAddress 192.168.10.10
```

### Add Domain Name option to DHCP scope
To ensure clients receive the correct domain suffix, add the Domain Name System (DNS) Domain Name option (Option ID 15) to your DHCP scope.
```powershell
Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 -OptionId 15 -Value "lab.local" -Force
```

## 2. Join a Computer to the Domain
Client computers need to be joined to the domain to benefit from Active Directory services. This command prompts for the domain administrator password and then joins the computer to the specified domain, renaming it in the process and initiating a restart.
```powershell
$Username = "LAB\Administrator"
$Password = Read-Host -Prompt "Enter the Domain Admin password" -AsSecureString
$Credential = New-Object System.Management.Automation.PSCredential($Username, $Password)
Add-Computer -DomainName "lab.local" -NewName "PC-01" -Credential $Credential -Restart
```

## 3. Manage Organizational Units (OUs)

### Create OU
Organizational Units (OUs) are containers within a domain that help organize objects like users, groups, and computers. This example creates "IT" and "HR" OUs.
```powershell
New-ADOrganizationalUnit -Name "IT" -Path "DC=lab,DC=local"
New-ADOrganizationalUnit -Name "HR" -Path "DC=lab,DC=local"
```

## 4. Manage Active Directory Groups

### Create AD group
Groups are used to manage permissions for multiple users efficiently. Here, we create two security groups: "IT Admins" and "HR Users".
```powershell
New-ADGroup -Name "IT Admins" -GroupScope Global -GroupCategory Security -Path "OU=IT,DC=lab,DC=local"
New-ADGroup -Name "HR Users" -GroupScope Global -GroupCategory Security -Path "OU=HR,DC=lab,DC=local"
```

## 5. Manage Active Directory Users

### Create AD user
User accounts are essential for individuals to access network resources. These commands create two new user accounts, "Admin 1" and "User 1", with specified attributes and paths within the OUs.
```powershell
New-ADUser -Name "Admin 1" -SamAccountName "admin1" -UserPrincipalName "admin1@lab.local" -AccountPassword (ConvertTo-SecureString "Pass@123" -AsPlainText -Force) -Enabled $true -Path "OU=IT,DC=lab,DC=local" -PasswordNeverExpires $true
New-ADUser -Name "User 1" -SamAccountName "user1" -UserPrincipalName "user1@lab.local" -AccountPassword (ConvertTo-SecureString "Pass@123" -AsPlainText -Force) -Enabled $true -Path "OU=HR,DC=lab,DC=local" -PasswordNeverExpires $true
```

### Add user to AD group
After creating users, add them to the relevant groups for permission assignment.
```powershell
Add-ADGroupMember -Identity "IT Admins" -Members "admin1"
Add-ADGroupMember -Identity "HR Users" -Members "user1"
```

## 6. Verify Active Directory Configuration
Finally, verify the creation of users and their group memberships using `Get-ADUser` and `Get-ADGroupMember`.
```powershell
Get-ADUser -Filter * | Select-Object Name, SamAccountName
Get-ADGroupMember -Identity "IT Admins"
Get-ADGroupMember -Identity "HR Users"
```
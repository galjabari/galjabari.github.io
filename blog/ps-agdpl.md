---
layout: default
title: "AGDLP Principle with PowerShell"
categories: ["Windows Server Administration", "Active Directory"]
tags: ["Windows Server", "Active Directory", "AGDLP", "PowerShell", "Permissions"]
---

# AGDLP Principle with PowerShell

This lab demonstrates how to implement the AGDLP principle by creating users, global groups, domain local groups, and assigning permissions to a shared folder. AGDLP is a recommended best practice for managing permissions in Active Directory.

The AGDLP principle is a hierarchical approach to assigning permissions:

*   **A**ccounts: User and computer accounts become members of Global groups.
*   **G**lobal Groups: Contain user accounts from the same domain. Global groups are members of Domain Local groups.
*   **D**omain Local Groups: Define permissions to resources. Domain Local groups typically contain Global groups from the same domain.
*   **P**ermissions: Assigned to Domain Local groups on resources (files, folders, shares, etc.).

### 1. Create Organizational Units (OUs)

First, create an OU to organize users and groups.
```powershell
New-ADOrganizationalUnit -Name "Staff" -Path "DC=lab,DC=local"
```

### 2. Create User Accounts (Accounts)

Create user accounts in the `Staff` OU.
```powershell
New-ADUser -Name "HR User 1" -SamAccountName "hruser1" -UserPrincipalName "hruser1@lab.local" -AccountPassword (ConvertTo-SecureString "Pass@123" -AsPlainText -Force) -Enabled $true -Path "OU=Staff,DC=lab,DC=local" -PasswordNeverExpires $true
New-ADUser -Name "HR User 2" -SamAccountName "hruser2" -UserPrincipalName "hruser2@lab.local" -AccountPassword (ConvertTo-SecureString "Pass@123" -AsPlainText -Force) -Enabled $true -Path "OU=Staff,DC=lab,DC=local" -PasswordNeverExpires $true
```

### 3. Create Global Groups (Global Groups)

Create Global groups in the `Staff` OU and add the user accounts to them. Global groups should reflect job roles or departments.
```powershell
New-ADGroup -Name "HRUsersGG" -GroupScope Global -GroupCategory Security -Path "OU=Staff,DC=lab,DC=local"
Add-ADGroupMember -Identity "HRUsersGG" -Members "hruser1"
Add-ADGroupMember -Identity "HRUsersGG" -Members "hruser2"
```

### 4. Create Domain Local Groups (Domain Local Groups)

Create Domain Local groups in the `Staff` OU. These groups will be assigned permissions to resources.
```powershell
New-ADGroup -Name "HRFilesDLG" -GroupScope DomainLocal -GroupCategory Security -Path "OU=Staff,DC=lab,DC=local"
```

### 5. Nest Global Groups into Domain Local Groups

Add the Global groups to their respective Domain Local groups.
```powershell
Add-ADGroupMember -Identity "HRFilesDLG" -Members "HRUsersGG"
```

### 6. Create Shared Folder and Assign NTFS Permissions (Permissions)

Create a shared folder, disable inheritance, and assign NTFS permissions to the Domain Local groups.

```powershell
# Create folder
New-Item -Path "D:\HR Files" -ItemType Directory

# Disable inheritance for HR Files folder
$Acl = Get-Acl -Path "D:\HR Files"
$Acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path "D:\HR Files" -AclObject $Acl

# Apply NTFS permissions for HRFilesDLG
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("LAB\HRFilesDLG", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Rule)
Set-Acl -Path "D:\HR Files" -AclObject $Acl

# Create SMB Share
New-SmbShare -Name "HRFilesShare" -Path "D:\HR Files" -ChangeAccess "Authenticated Users"

Test-Path "\\localhost\HRFilesShare"
```

## 7. Verify AGDLP Implementation

Verify the group memberships and effective permissions.
```powershell
Get-ADGroupMember -Identity "HRUsersGG"
Get-ADGroupMember -Identity "HRFilesDLG"

# Verify NTFS permissions
Get-Acl -Path "D:\HR Files" | Select-Object -ExpandProperty Access


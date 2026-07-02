---
layout: default
title: "File Server on Windows Server"
categories: ["Windows Server Administration", "File Server"]
tags: ["Windows Server", "File Server", "Storage", "PowerShell"]
---

# File Server on Windows Server

This lab guides you through setting up a basic file server on Windows Server 2022, including creating a new volume, managing local users and groups, configuring NTFS permissions, and creating a shared folder.

## 1. Create and Format a New Storage Volume
When adding a new disk to your server, you need to bring it online, initialize it, create a partition, and format it. This sequence of commands automates that process.
```powershell
# Identify new disk
Get-Disk
# Bring the disk online
Set-Disk -Number 1 -IsOffline $false
# Initialize disk
Initialize-Disk -Number 1 -PartitionStyle GPT
# Create partition 
$partition = New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
# Format new partition
Format-Volume -DriveLetter $partition.DriveLetter -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false
```

## 2. Manage Local Users and Groups

### Create local user
To control access to shared resources, you often need to create local user accounts. This command creates a new local user with a specified password and ensures the password never expires.
```powershell
$Password = ConvertTo-SecureString "Pass@123" -AsPlainText -Force
New-LocalUser -Name "user" -Password $Password -FullName "User" -PasswordNeverExpires
```

### Add user to local group
Adding users to local groups simplifies permission management. Here, we add the newly created user to the local "Users" group.
```powershell
Add-LocalGroupMember -Group "Users" -Member "user"
```

## 3. Configure NTFS Permissions

### Create folder
First, create the folder where you intend to store shared files. This example creates a `Documents` folder on the `D:` drive.
```powershell
New-Item -Path "D:\Documents" -ItemType Directory
```

### Disable inheritance
By default, folders inherit permissions from their parent. To set explicit permissions, you often need to disable inheritance. The `$Acl.SetAccessRuleProtection($True, $True)` command copies existing inherited permissions before disabling inheritance.
```powershell
# Get current ACL
$Acl = Get-Acl -Path "D:\Documents"
# Copy current inherited rules
$Acl.SetAccessRuleProtection($True, $True)
# Apply updated ACL
Set-Acl -Path "D:\Documents" -AclObject $Acl
```

### Apply NTFS permissions
Now, apply specific NTFS permissions to the folder. This example grants the built-in "Users" group "Modify" access, allowing them to create, read, write, and delete files and subfolders.
```powershell
# Get current ACL
$Acl = Get-Acl -Path "D:\Documents"
# Define NTFS permission
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
# Add new ACL
$Acl.SetAccessRule($Rule)
# Apply updated ACL
Set-Acl -Path "D:\Documents" -AclObject $Acl
```

### Verify
To verify the applied NTFS permissions, retrieve the Access Control List (ACL) for the folder and display relevant properties.
```powershell
$Acl = Get-Acl -Path "D:\Documents"
$Acl.Access | Select-Object IdentityReference, FileSystemRights, IsInherited, AccessControlType
```

## 4. Create a Network Share
To make the folder accessible over the network, create a new SMB share. This command creates a share named "Documents" pointing to `D:\Documents` and grants "Authenticated Users" change access.
```powershell
New-SmbShare -Name "Documents" -Path "D:\Documents" -ChangeAccess "Authenticated Users"
Test-Path "\\localhost\Documents"
```
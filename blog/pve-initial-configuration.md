---
layout: default
title: "Proxmox VE Initial Configuration"
categories: ["Proxmox VE Administration", "Initial System Configuration"]
tags: ["Proxmox VE", "Configuration", "Linux", "CLI"]
---

# Proxmox VE Initial Configuration

This lab guides you through the essential initial configuration steps for a Proxmox VE 9.1 installation. We will cover checking the system version, configuring repositories for updates, setting the system timezone, and removing the subscription nag message.

## 1. Verify Proxmox VE Version

It's always good practice to verify the installed Proxmox VE version. This command displays detailed version information about your Proxmox installation and its components.
```bash
pveversion
```

## 2. Configure Package Repositories

Proxmox VE comes with enterprise repositories enabled by default, which require a subscription for updates. For home lab or non-production environments, you can disable these and add the no-subscription repository.

### Disable enterprise repository
This command disables the enterprise repository by appending `Enabled: false` to its configuration file. This prevents your system from attempting to fetch updates from the enterprise repository.
```bash
echo "Enabled: false" | tee -a /etc/apt/sources.list.d/pve-enterprise.sources
```

### Disable ceph repository
If you are not using Ceph storage, you can also disable the Ceph repository to avoid unnecessary update checks.
```bash
echo "Enabled: false" | tee -a /etc/apt/sources.list.d/ceph.sources
```

### Add no-subscription repository
This step adds the official Proxmox VE no-subscription repository, allowing you to receive regular updates without an active subscription. The `cat` command is used here to create a new `.sources` file with the repository details.
```bash
cat > /etc/apt/sources.list.d/proxmox.sources << EOF 
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
```

### Update package lists
After modifying the repositories, it's crucial to update your package lists. This command fetches the latest package information from all configured repositories.
```bash
apt-get update
```

### Upgrade packages
Once the package lists are updated, upgrade all installed packages to their latest versions. The `-y` flag automatically confirms any prompts.
```bash
apt-get dist-upgrade -y
```

## 3. Set System Timezone

Accurate time synchronization is vital for many system services and logging. Set your server's timezone to reflect your geographical location.

Replace `<Region/City>` with your desired timezone (e.g., `Asia/Gaza`). You can list available timezones using `timedatectl list-timezones`.
```bash
timedatectl set-timezone <Region/City>
```

## 4. Remove Subscription Message (Optional)

Proxmox VE displays a subscription reminder in the web interface for systems without an active subscription. This step removes that message.

This `sed` command modifies the `proxmoxlib.js` file to hide the subscription status message. A backup of the original file is created (`.bak`). After modifying the file, the `pveproxy.service` needs to be restarted for the change to take effect.
```bash
sed -i.bak '/.*res\.data\.status.*/{s/!//; s/active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
systemctl restart pveproxy.service
```
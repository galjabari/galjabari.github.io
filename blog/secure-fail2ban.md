---
layout: default
title: "Secure a Server with Fail2Ban"
---

# Secure a Server with Fail2Ban

This lab guides you through the process of installing and configuring Fail2Ban on an Ubuntu server to protect it from brute-force attacks. You will then use Kali Linux to simulate a brute-force attack and verify Fail2Ban's effectiveness.

## Prerequisites

*   An Ubuntu Server (e.g., Ubuntu 24.04 LTS) with SSH access.
*   A Kali Linux virtual machine or system with network connectivity to the Ubuntu server.

### 1. Install Fail2Ban on Ubuntu

First, update your package list and install the `fail2ban` package on your Ubuntu server.

```bash
sudo apt update
sudo apt install fail2ban -y
```

After installation, verify that the `fail2ban` service is running correctly.

```bash
sudo systemctl status fail2ban
```

You should see output indicating the service is `active (running)`.

### 2. Configure Fail2Ban

Fail2Ban's default configuration is in `/etc/fail2ban/jail.conf`. To make persistent changes that won't be overwritten during package updates, it's best practice to copy this file to `jail.local` and make your modifications there.

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

Now, open `jail.local` for editing:

```bash
sudo nano /etc/fail2ban/jail.local
```

Locate the `[sshd]` section. Ensure it is enabled. By default, it should look something like this:

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 10m
findtime = 10m
```

You can adjust `maxretry` (number of failed attempts before banning) and `bantime` (duration of the ban) if desired. For this lab, the defaults are usually sufficient.

Save and exit the editor (Ctrl+X, Y, Enter).

After modifying `jail.local`, restart the Fail2Ban service to apply your changes.

```bash
sudo systemctl restart fail2ban
```

### 3. Check Fail2Ban Status

You can check the overall status of Fail2Ban and the status of specific "jails" (configurations for protecting specific services), such as the `sshd` jail that protects against SSH brute-force attacks.

```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

The output should show the `sshd` jail is running and list any currently banned IP addresses (initially none).

### 4. Enable Password Authentication for SSH

For this lab, we'll intentionally allow password authentication on SSH to demonstrate Fail2Ban's effectiveness against brute-force attacks. In a production environment, it is generally recommended to use SSH keys instead of passwords.

Open the SSH daemon configuration file:

```bash
sudo nano /etc/ssh/sshd_config
```

Ensure the following lines are uncommented and set to `yes`:

```
PasswordAuthentication yes
KbdInteractiveAuthentication yes
```

Save and exit the editor (Ctrl+X, Y, Enter).

Restart the SSH service to apply the changes to `sshd_config`.

```bash
sudo systemctl restart ssh
```

### 5. Simulate a Brute-Force Attack

From your Kali Linux machine, you will use `hydra` to simulate a brute-force attack against your Ubuntu server's SSH service.

**Before you begin:**
*   Replace `<TARGET_SERVER_IP>` with the actual IP address of your Ubuntu server.
*   The `/usr/share/wordlists/rockyou.txt` is a common wordlist on Kali Linux. If it's not present, you might need to locate another wordlist or generate a small custom one for testing.

Run the attack command:

```bash
hydra -l ubuntu -P /usr/share/wordlists/rockyou.txt <TARGET_SERVER_IP> ssh -t 4 -V
```

This command attempts to log in as the user `ubuntu` using passwords from the `rockyou.txt` wordlist via SSH. The `-t 4` limits concurrent tasks to 4, and `-V` shows details. After a few failed attempts, Fail2Ban should ban your Kali Linux IP.

### 6. Verification

While the Hydra attack is running (or shortly after it has made several attempts), switch back to your Ubuntu server and check the Fail2Ban `sshd` jail status again.

```bash
sudo fail2ban-client status sshd
```

You should now see the IP address of your Kali Linux machine listed under `Banned IP list`. This confirms Fail2Ban has successfully detected and banned the brute-force attacker.

If you need to regain SSH access from the Kali Linux machine (or any banned IP), you can manually unban it using the `fail2ban-client` command.

**Before you begin:**
*   Replace `<ATTACK_MACHINE_IP>` with the actual IP address of your Kali Linux machine.

```bash
sudo fail2ban-client set sshd unbanip <ATTACK_MACHINE_IP>
```

Verify that the IP has been unbanned:

```bash
sudo fail2ban-client status sshd
```

The Kali Linux IP address should no longer appear in the `Banned IP list`. You should now be able to SSH into your Ubuntu server from the Kali Linux machine again.

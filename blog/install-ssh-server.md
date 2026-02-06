---
title: "Install and configure an SSH Server on Ubuntu"
description: "step-by-step guide on how to install SSH server on Ubuntu 20.04/22.04 to remotely access your system"
---

# Install and configure an SSH Server on Ubuntu

First, update your package lists to ensure you have the latest versions available:

```
sudo apt update
```

Next, install the OpenSSH server package:

```
sudo apt install openssh-server -y
```

Once the installation is complete, the SSH server should start automatically. You can verify its status by running:

```
sudo systemctl status ssh.service
```

If the service is active, you are ready to connect.

## Connect to the SSH Server

To connect to the SSH server from another machine, you will need the server's IP address and a valid username. For example, if the server's IP is `192.168.1.10` and your username is `ubuntu`, use the following command:

```
ssh ubuntu@192.168.1.10
```

The first time you connect, you may be asked to confirm the host's authenticity. After confirming and entering your password, you will be logged in.

## Configure SSH key-based authentication

For a more secure and convenient way to log in, you can set up SSH key-based authentication. This allows you to connect without entering a password each time.

On your local (client) machine, generate an SSH key pair by running:

```
ssh-keygen
```

You can accept the default location (`~/.ssh/id_ed25519`) and optionally set a passphrase for added security.

Next, copy the public key to the remote server. The easiest way is to use the `ssh-copy-id` utility:

```
ssh-copy-id ubuntu@192.168.1.10
```

Alternatively, you can copy the key manually. First, display the public key on your local machine:

```
cat ~/.ssh/id_ed25519.pub
```

Then, on the server, open the `authorized_keys` file in a text editor:

```
nano ~/.ssh/authorized_keys
```

Paste your public key into this file and save it.

You should now be able to connect to the server using your SSH key:

```
ssh ubuntu@192.168.1.10
```

If you set a passphrase when creating the key, you will be prompted to enter it.

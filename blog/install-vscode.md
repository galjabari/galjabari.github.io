---
title: "Install VS Code on Ubuntu"
---

# Install VS Code on Ubuntu

Visual Studio Code (VS Code) is a popular code editor that supports various programming languages and extensions. It is available for multiple platforms, including Linux. In this guide, we will walk through the steps to install VS Code on Ubuntu.

First, add the Microsoft repository to get the latest version:

```
sudo apt update
sudo apt install wget gpg apt-transport-https software-properties-common -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm -f microsoft.gpg
echo -e "Types: deb\nURIs: https://packages.microsoft.com/repos/code\nSuites: stable\nComponents: main\nArchitectures: amd64,arm64,armhf\nSigned-By: /usr/share/keyrings/microsoft.gpg" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null
```

Next, update the package list and install VS Code:

```
sudo apt update
sudo apt install code -y
```

If you have Docker installed, you can also install the official Docker extension to help build and deploy containerized applications. To do so, open the Extensions view in VS Code, search for `docker`, and select the extension published by Microsoft.

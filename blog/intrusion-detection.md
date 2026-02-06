---
title: "Intrusion Detection with Suricata"
description: "A step-by-step guide on how to install and configure Suricata IDS/IPS on Ubuntu 20.04/22.04"
---

# Intrusion Detection with Suricata

First, update package lists to ensure you have the latest versions of all packages:

```
sudo apt update
```

You can install Suricata from the official repository:

```
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes ppa:oisf/suricata-stable
sudo apt-get install suricata -y
```

After installation, you need to configure Suricata by editing the main configuration file:

```
sudo nano /etc/suricata/suricata.yaml
```

In this file, you need to specify the network interfaces to monitor in the `af-packet` section:

```
af-packet:
    - interface: eth0
```

Replace `eth0` with your actual network interface, which you can find using the `ip addr` command.

Enable and start the Suricata service with the following commands:

```
sudo systemctl enable suricata.service
sudo systemctl start suricata.service
```

To update Suricata signatures or rules, you can use the `suricata-update` tool:

```
sudo suricata-update
```

After updating the rules, restart the Suricata service to ensure it loads the new rules:

```
sudo systemctl restart suricata.service
```

To test the functionality of Suricata, open a new terminal to check the log:

```
sudo tail -f /var/log/suricata/fast.log
```

Use `curl` to trigger the rule from the ET Open ruleset, which is written specifically for test.

```
curl http://testmynids.org/uid/index.html
```

You should see an alert in the log, including the timestamp and the IP address of your system.

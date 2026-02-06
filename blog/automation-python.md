# Network Automation with Python

To automate network device configuration such as interface settings, VLAN configurations, or routing protocols, you can use Netmiko library in Python.

First, ensure your network device supports SSH and has SSH enabled.

Here's an example to setup SSH on a Cisco switch for remote management. Execute the following commands using a console cable:

```
Switch>en
Switch#conf t
Switch(config)#hostname S1
S1(config)#ip domain-name example.com
S1(config)#crypto key generate rsa
S1(config)#ip ssh version 2
S1(config)#username admin privilege 15 secret pass@123
S1(config)#line vty 0 4
S1(config-line)#transport input ssh
S1(config-line)#login local
S1(config-line)#exit
S1(config)#interface vlan 1
S1(config-if)#ip address 192.168.1.1 255.255.255.0
S1(config-if)#no shut
S1(config-if)#exit
S1(config)#exit
```

Make sure to choose a key size of 1024 bits or higher when prompted to generate RSA key. Replace `192.168.1.1` with the IP address of your network device.

After setting up SSH on the Cisco switch, connect your Linux machine to the switch and create a folder for Python script:

```
mkdir tasks
```

Inside the folder, create a virtual environment and activate it:

```
cd tasks
python3 -m venv .venv
source .venv/bin/activate
```

Install the `Netmiko` via `pip` if you haven't already:

```
pip install netmiko
```

Here's a Python script to configure a network device. Create a new Python file using your preferred editor:

```
nano config_switch.py
```

For example, add the following script to configure VLANs on a Cisco switch:

```python
from netmiko import ConnectHandler

device = {
    'device_type': 'cisco_ios',
    'host': '192.168.1.1',
    'username': 'admin',
    'password': 'pass@123',
}

net_connect = ConnectHandler(**device)

config_commands = [
    'vlan 10',
    'name VLAN10',
    'exit',
    'vlan 20',
    'name VLAN20',
    'exit'
]

output = net_connect.send_config_set(config_commands)
print(output)
net_connect.disconnect()
```

Save the script and run it using Python:

```
python3 config_switch.py
```

To save the configuration changes, you can use `save_config()` method:

```python
output += net_connect.save_config()
print(output)
```

To apply the configuration commands specified in a file, you can use `send_config_from_file()` method:

```python
output = net_connect.send_config_from_file('config_commands.txt')
print(output)
```

Make sure Python script and `config_commands.txt` file are in the same directory.

## Configure multiple devices

To connect to multiple network devices, you need to ensure SSH is configured on each device.

Here's a Python script to configure multiple devices using Netmiko. Create a new Python file:

```
nano config_vlans.py
```

For example, add the following script to configure VLANs on Cisco switches:

```python
from netmiko import ConnectHandler

switch1 = {
    'device_type': 'cisco_ios',
    'host': '192.168.1.1',
    'username': 'admin',
    'password': 'pass@123',
}

switch2 = {
    'device_type': 'cisco_ios',
    'host': '192.168.1.2',
    'username': 'admin',
    'password': 'pass@123',
}

switch3 = {
    'device_type': 'cisco_ios',
    'host': '192.168.1.3',
    'username': 'admin',
    'password': 'pass@123',
}

config_commands = [
    'vlan 10',
    'name VLAN10',
    'exit',
    'vlan 20',
    'name VLAN20',
    'exit'
]

for device in (switch1, switch2, switch3):
    net_connect = ConnectHandler(**device)
    output = net_connect.send_config_set(config_commands)
    print(output)
    net_connect.disconnect()
```

Save the script and run it using Python:

```
python3 config_vlans.py
```

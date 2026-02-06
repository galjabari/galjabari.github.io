# Deploy a Web Server with Containerlab

This guide demonstrates how to deploy a web server using Containerlab in a data center topology. The lab consists of a three routers, a desktop client, and a web server.

## 1. Create a lab topology

The lab topology is defined in the `web.clab.yml` file:

```
name: web
topology:
  nodes:
    # Spine (Arista cEOS)
    spine:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: spine.cfg
    # Leaf 1 (Arista cEOS)
    leaf1:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: leaf1.cfg
    # Leaf 2 (Arista cEOS)
    leaf2:
      kind: arista_ceos
      image: takfa19/ceos:4.32.2F
      startup-config: leaf2.cfg
    # Desktop (Linux container)
    desktop:
      kind: linux
      image: lscr.io/linuxserver/webtop:latest
      ports:
        - 3000:3000
        - 3001:3001
      exec:
        - ip addr add 192.168.10.2/24 dev eth1
        - ip route replace default via 192.168.10.1
    # Server (Linux container)
    server:
      kind: linux
      image: nginx:alpine
      exec:
        - ip addr add 192.168.20.2/24 dev eth1
        - ip route replace default via 192.168.20.1
  links:
    # Link between spine and leaf 1
    - endpoints: ["spine:eth1", "leaf1:eth1"]
    # Link between spine and leaf 2
    - endpoints: ["spine:eth2", "leaf2:eth1"]
    # Link between leaf 1 and desktop
    - endpoints: ["leaf1:eth2", "desktop:eth1"]
    # Link between leaf 2 and server
    - endpoints: ["leaf2:eth2", "server:eth1"]
```
## 2. Create startup configurations

Each router in the topology has a startup configuration file that defines its interfaces, IP addresses, and OSPF routing protocol settings.

Here are the configurations for spine router (`spine.cfg`):
```
!
enable
configure
!
username admin privilege 15 secret admin
!
ip routing
!
interface Ethernet1
  no switchport
  ip address 192.168.1.2/30
!
interface Ethernet2
  no switchport
  ip address 192.168.1.6/30
!
interface Loopback0
  ip address 10.10.10.3/32
!
router ospf 1
  router-id 10.10.10.3
  network 192.168.1.0/30 area 0
  network 192.168.1.4/30 area 0
!
end
```
The leaf routers are configured similarly, with different IP addresses and loopback addresses.

Here are the configurations for leaf1 router (`leaf1.cfg`):
```
!
enable
configure
!
username admin privilege 15 secret admin
!
ip routing
!
interface Ethernet1
  no switchport
  ip address 192.168.1.1/30
!
interface Ethernet2
  no switchport
  ip address 192.168.10.1/24
!
interface Loopback0
  ip address 10.10.10.1/32
!
router ospf 1
  router-id 10.10.10.1
  network 192.168.1.0/30 area 0
  network 192.168.10.0/24 area 0
!
end
```
And for leaf2 router (`leaf2.cfg`):
```
!
enable
configure
!
username admin privilege 15 secret admin
!
ip routing
!
interface Ethernet1
  no switchport
  ip address 192.168.1.5/30
!
interface Ethernet2
  no switchport
  ip address 192.168.20.1/24
!
interface Loopback0
  ip address 10.10.10.2/32
!
router ospf 1
  router-id 10.10.10.2
  network 192.168.1.4/30 area 0
  network 192.168.20.0/24 area 0
!
end
```
## 3. Deploy the lab

To deploy the lab, navigate to the directory containing the files and run:

```
clab deploy -t web.clab.yml
```

This command creates the lab topology and configures the devices with the specified startup configurations.

To access the desktop client, open a web browser and navigate to `http://localhost:3000` or `https://localhost:3001`.

From the desktop client, you can access the web server by navigating to `http://192.168.20.2` in its browser.

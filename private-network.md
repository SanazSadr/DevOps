# Setup NAT Private Network

## What is NAT?

Network address translation (NAT) is a method of remapping one IP address space into another by modifying network address information in Internet Protocol (IP) datagram packet headers while they are in transit across a traffic routing device.

In this article, we are going to configure P-NAT. Port Network Address Translation or P-NAT, uses a single outside public address and maps multiple inside addresses to it using different port numbers. It is mainly used for Internet connection sharing on a private IP address space.

![NAT-router](/assets/private-network-NAT-router.jpg)

## Set Static IP Address

At first add one network interface of type "VMnet0" to your server, then:

![server](/assets/private-network-server.jpg)

```bash
vim /etc/netplan/00-installer-config.yaml

# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 192.168.211.101/24
      gateway4: 192.168.211.2  
    ens37:
      dhcp4: false
      addresses:
        - 192.168.10.1/24


netplan try    
```

##  Enable IP-Forwarding

Now you need to enable IP Forwarding. It allows the OS to exchange IP Packets between NIC Cards based on their IP Network targets. By default, IP Forwarding is disabled in most of the Linux based operating systems.

```bash
# check ip forwarding status
sysctl net.ipv4.ip_forward
cat /proc/sys/net/ipv4/ip_forward

# enable ip forwarding
sysctl -w net.ipv4.ip_forward=1
echo 1 > /proc/sys/net/ipv4/ip_forward
```

## Install iptables

```bash
apt install iptables

# enable NAT using iptables
iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE

apt install iptables-persistent
```

## Connect the Client Machine and test the P-NAT Connection

On your client server, you just need one network interface of type "VMnet0"

![client](/assets/private-network-client.jpg)

```bash
vim /etc/netplan/00-installer-config.yaml

# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 192.168.10.10/24
      gateway4: 192.168.10.1

netplan try

ping google.com
```

![ping-google](/assets/private-network-ping-google.jpg)

## Source of content

[Configure Tiny Core Linux as NAT (P-NAT) Router using iptables](https://iotbytes.wordpress.com/configure-microcore-tiny-linux-as-nat-p-nat-router-using-iptables/)
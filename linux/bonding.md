# Setup Bond

## What is Network Bonding?

Also referred to as link aggregation, **Network Interface Card (NIC)** bonding, or simply network bonding, is the joining together of two physical network interfaces into a single logical interface.<br>
Network bonding combines multiple **LAN** or **Ethernet** interfaces into a single logical interface known as a network bond.<br>
The goal of network bonding is to provide fault tolerance and network redundancy. It also enhances capacity and improves network throughput depending on the type of bond created.

## Enable Bonding in Ubuntu

At first add one or more network interfaces to your server in order to join them into a single logical interface. Then:

```bash
# install package
apt install ifenslave

# enable module
modprobe bonding

# check module
lsmod | grep bonding
####################
bonding               200704  0
tls                   114688  1 bonding
####################
```

## Configure Permanent Network Bonding in Ubuntu

The next step is to configure a network bond. Remember that this will only be a temporary bond and will not persist in a reboot.

```bash
apt install net-tools
ifconfig ens37 192.168.211.100 netmask 255.255.255.0
ifconfig
```
![ifconfig](/assets/bonding-ifconfig.jpg)

```bash
vim /etc/netplan/00-installer-config.yaml

###################################################
# This is the network config written by 'subiquity'
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
    ens37:
      dhcp4: false
  bonds:
    bond0:
      dhcp4: false
      interfaces:
        - ens33
        - ens37
      addresses:
        - 192.168.211.200/24
      parameters:
        mode: active-backup
        primary: ens33
        mii-monitor-interval: 100
###################################################

netplan apply
ip addr
```

![netplan-apply](/assets/bonding-netplan-apply.jpg)


In addition, you can check detailed info about the network bond

```bash
cat /proc/net/bonding/bond0
```

![check-bond0](/assets/bonding-check-bond0.jpg)


## Source of content

[A Beginner’s Guide to Creating Network Bonding and Bridging in Ubuntu](https://www.tecmint.com/create-network-bond-bridge-in-ubuntu/) <br>
[Ubuntu 22.04 LTS Network Bonding – Active/Standby](https://geekmungus.co.uk/?p=3981) <br>
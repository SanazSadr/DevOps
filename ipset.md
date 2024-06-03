# Install and Configure ipset

## What is ipset?

A tool consisting of a kernel module, libraries and utility, allowing you to organize a list of networks, IP or MAC addresses, etc., which is very convenient to use for example with IPTables.

## Installing ipset

```bash
apt install ipset
```

The possible types of list:
- net (networks for example 192.168.5.0/24)
- ip (ip only, for example 192.168.5.5)
- mac (MAC addresses, for example 11:22:33:44:55:66)
- port (ports, convenient when creating lists ip,port)
- iface (network interfaces, convenient when creating lists of ip, iface)

Here are some examples (where test-list is the name of the list):

```bash
# create a list
ipset -N test-list nethash
ipset create test-list nethash
ipset create test-list hash:net
ipset create test-list hash:ip
ipset create test-list hash:ip,port
ipset create test-list hash:ip,iface
ipset create test-list hash:mac

# delete a list
ipset destroy test-list

# add data to list
ipset add test-list 192.168.5.5/24
ipset add test-list 192.168.5.5
ipset add test-list 192.168.5.5,80
ipset add test-list 192.168.5.5,udp:1812
ipset add test-list 192.168.5.5,eth0
ipset add test-list 11:22:33:44:55:66

# remove an item from list
ipset del test-list 192.168.5.5

# view lists
ipset -L
ipset --list
ipset -L ixnfo

# rename lists
ipset –e OLDNAME NEWNAME
ipset –e test-list new-list
```

![ipset-lists](/assets/ipset-lists.jpg)

Now when we have a list created, manually or it fills the script using ipset and iptables for example, it is very convenient to deny access to the server to all addresses that are in the list or allow access to everyone except the addresses in the list:

```bash
# deny
iptables -I INPUT -m set --match-set test-list src -j DROP

# allow
iptables -I INPUT -m set ! --match-set test-list src -j ACCEPT
```

## Making ipset Persistent

The ipset you have created is stored in memory and will be gone after reboot. To make the ipset persistent you have to do the followings:

First, save the ipset to /etc/ipset.conf

```bash
ipset save > /etc/ipset.conf
```

## Source of content

[Installing and using ipset](https://ixnfo.com/en/installing-and-using-ipset.html) <br>
[Archlinux ipset](https://wiki.archlinux.org/title/Ipset)
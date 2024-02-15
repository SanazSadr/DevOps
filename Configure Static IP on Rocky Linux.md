# Configure Static IP on Rocky Linux

## Set static IP using network-script

Create a script with this command in `/etc/sysconfig/network-scripts` directory:

``` bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-ens33
```

**Note:** If the interface's name is `ens33`, the file's name will be `/etc/sysconfig/network-scripts/ifcfg-ens33`.

Add the flowing lines in the file:

``` bash
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=ens33
DEVICE=ens33
ONBOOT=yes
IPADDR=192.168.211.100
NETMASK=255.255.255.0
GATEWAY=192.168.211.2
DNS1=4.2.2.4
DNS2=8.8.8.8
```

**Note:** The value of the parameters `Name` and `Device` should be the name of the interface. In this case is `ens33`.

To activate the configuration, run the command below:

``` bash
sudo systemctl restart NetworkManager
```

To verify your changes, run the command below:

```bash
nmcli connection show
```

Then Run these commands to activate your given ip:

```bash
sudo nmcli networking off
sudo nmcli networking on
```

Now the result of `ip -br a` should be this:

```bash
lo               UNKNOWN        127.0.0.1/8 ::1/128
ens33            UP             192.168.211.100/24 fe80::448b:7563:d2b2:73b6/64
```

**NOTE:** After changing your IP, you should change the configuration on any SSH Client software you have on your pc.
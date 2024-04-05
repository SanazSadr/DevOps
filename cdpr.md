# cdpr - Cisco Discovery Protocol Reporter

## What is cdpr?

The default behaviour is to send a CDP/LLDP trigger packet on startup (unless -s is specified) and send a regular CDP/LLDP packet every minute. After one CDP/LLDP packet has been received, the program will quit unless -c is specified. All available Ethernet interfaces on a host are used for sending and receiving, unless -i or -d is specified. Use -l to see what adapters are available to specify using -d. After 300 seconds the program will quit, unless specified otherwise using -t. Regular TLVs are reported by default and all known TLVs are reported by specifying -v. Unknown TLVs are also reported by specifying -vv.

## Install package

```bash
apt install cdpr
```

## Command line options

```
-a: LLDP 802.1AB only mode
-o: CDP only mode
-c: Continuous capture mode; does not stop upon first reception
-s: Silent mode; do not send trigger packet
-i: Interactive mode; lets user pick a device to listen on
-l: Lists devices
-d: Specify device to use (eth0, hme0, etc.)
-h: Print usage
-t: Time in seconds to abort waiting for packets (default is 300)
-v[vv]: Set verbose mode
```

![cdpr](/assets/cdpr.jpg)


## Source of content

[cdpr-3.0](https://github.com/tdorssers/cdpr-3.0/blob/master/README.md) <br>
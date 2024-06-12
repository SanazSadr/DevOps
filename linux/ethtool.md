# ethtool

## What is ethtool?

The `ethtool` command in Linux is a versatile tool used for managing Ethernet devices. It allows you to view and change your network device settings, such as speed, port, auto-negotiation, and many more. It’s an essential tool for system administrators who need to troubleshoot network issues.

## Install ethtool

```bash
apt install ethtool
ethtool --version
ethtool ens33
```

![ethtool](/assets/ethtool.jpg)

## Cheat sheet

```bash
# To show statistics for the selected interface:
ethtool -S 

# To show interface permanent address:
ethotool -P 

# To set interface speed:
ethtool -s  [ speed %d ]

# To set interface autonegotiation:
ethtool -s  [ autoneg on|off ]

# To get interface errors:
ethtool -S  | grep error
```

## Choosing The Right Tool

| Tool     | Advantages                                                  | Disadvantages                                     |
| -------- | ----------------------------------------------------------- | ------------------------------------------------- |
| ethtool  | Provides a lot of features for managing Ethernet devices    | Not as general as ‘ifconfig’ and ‘ip’             |
| ifconfig | Simple and easy to use                                      | Considered deprecated in many Linux distributions |
| ip       | Provides more features and is more powerful than ‘ifconfig’ | More complex to use than ‘ifconfig’               |

## Source of content

[Linux Ethtool Command Installation and Usage Guide](https://ioflood.com/blog/install-ethtool-command-linux/#:~:text=On%20Debian%2Dbased%20distributions%20like,%23%20Reading%20state%20information...) <br>
[ETHTOOL Commands Cheat Sheet](https://networkers-online.com/p/ethtool-commands-cheat-sheet)
# Setup GlusterFS

## Install GlusterFS

For this task you will need 3 ubuntu servers.

Run these commands on all three servers:

```bash
apt-get update
apt-get install -y software-properties-common
add-apt-repository ppa:gluster/glusterfs-9
apt-get update
apt install glusterfs-server
```
> **NOTE:** If you faces an **error** like this (Temporary failure resolving 'ir.archive.ubuntu.com') in last commands, do this:
> ```bash
> vim /etc/resolve.conf
>
> nameserver 8.8.8.8
> ```
> then try again.

> **NOTE:** `glusterfs-client` is installed with the last `apt install` command.

after the installation start, enable and check status of GlusterFS with theses commands:

```bash
systemctl start glusterd
systemctl enable glusterd
systemctl status glusterd
```

![GlusterFS-status](GlusterFS-status.jpg)


## Update 

We need to update `host` file because we're using private IPs.

```bash
vim /etc/hosts

192.168.211.101 node1
192.168.211.102 node2
192.168.211.103 node3
```

![etc-hosts](etc-hosts.jpg)

## Create GlusterFS Storage

To create a GlusterFS storage, you will need an external hard disk on each server.<br>
You will also need to create a partition on an external hard disk(/dev/sdb) on each server.

```bash
fdisk /dev/sdb # remember to set type as LVM
mkfs.ext4 /dev/sdb1
mkdir /glustervolume
mount /dev/sdb1 /glustervolume
vim /etc/fstab

/dev/sdb1 /glustervolume ext4 defaults 0 0
/dev/disk/by-uuid/938da461-1842-4928-94f7-f098f0e87e1d /glustervolume ext4 defaults 0 0

mount -a
df -h
```

![mounted-lvms](mounted-lvms.jpg)

## Configure GlusterFS Volume

Now it's time to connect our servers. Run these command on your first node.

```bash
gluster peer probe node1
gluster peer probe node2
gluster peer status
```

![gluster-peer-status](gluster-peer-status.jpg)

To verify the added storage pool with the following command:

```bash
gluster pool list
```
![gluster-pool-list](gluster-pool-list.jpg)

## Setup volumes

Create a brick directory on each node with the following command:

```bash
mkdir /glustervolume/vol1
```

Then create a volume named vol1 with three replicas by these commands on your primary server:

```bash
gluster volume create vol1 replica 3 node1:/glustervolume/vol1 node2:/glustervolume/vol1 node3:/glustervolume/vol1
gluster volume start vol1
gluster volume status
```

![gluster-volume](gluster-volume.jpg)

## Mounting GlusterFS on Clients

Create a directory where you want to mount the GlusterFS volume on your client machine:

```bash
mkdir /mnt/vol1
mount -t glusterfs node3:/vol1 /mnt/vol1
```

## Time to test

Make a file in one of the servers and check other to see the file you've made.

```bash
# Do this on the first server
touch /mnt/vol1/file1.txt
vim /mnt/vol1/file1.txt

Hello World!
```

![gluster-test](gluster-test.jpg)

## Source of content

[How to Install and Configure GlusterFS on Ubuntu 22.04](https://www.howtoforge.com/how-to-install-and-configure-glusterfs-on-ubuntu-22-04/) <br>
[How To Install GlusterFS on Ubuntu 22.04 LTS](https://idroot.us/install-glusterfs-ubuntu-22-04/) <br>
[How to Setup GlusterFS in Ubuntu](https://www.youtube.com/watch?v=gEG7Eu320Rk)
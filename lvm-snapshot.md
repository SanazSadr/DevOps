# lvm snapshot and restore

## Prerequisites

Run the `lvs` command in order to display existing logical volumes

```bash
  LV       VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv-0     ubuntu-vg -wi-ao---- <48.00g
  lvdisk22 vg-ssd    -wi-ao----   2.00g
```

Run the `df -h` to check the actual size of your logical volume

```bash
Filesystem                    Size  Used Avail Use% Mounted on
tmpfs                         388M  8.1M  380M   3% /run
/dev/mapper/ubuntu--vg-lv--0   47G   14G   31G  32% /
tmpfs                         1.9G   52K  1.9G   1% /dev/shm
tmpfs                         5.0M     0  5.0M   0% /run/lock
/dev/sda2                     2.0G  251M  1.6G  14% /boot
/dev/mapper/vg--ssd-lvdisk22  2.0G   24K  1.8G   1% /data_sdb1
tmpfs                         388M  4.0K  388M   1% /run/user/1000
```

Create files in your LV to restore them from snapshot later

![create-files](create-files.png)

## Creating LVM Snapshots using lvcreate

In order to create a LVM snapshot of a logical volume, you have to execute the `lvcreate` command with the `-s` option for `snapshot`, the `-L` option with the size and the name of the logical volume; you can specify a name for your snapshot with the `-n` option.

```bash
lvcreate -s -n 20240222_sdb1_snapshot -L 20M vg-ssd/lvdisk22
```

> **Note:** The snapshot size should be larger that the used size of your lv, otherwise some part of your data will be lost.<br>
> You will also have to make sure that you have enough remaining space in the volume group as the snapshot will be created in the same volume group by default.<br>
> You won’t be able to create snapshot names having “snapshot” in the name as it is a reserved keyword. The origin name should include the volume group.

![lvcreate](lvcreate.png)

Now to see your snapshot run the `lvs`

![lvs-snapshot](lvs-snapshot.png)

As you can see, the logical volume has a set of different attributes compared to the original logical volume :

- s : for snapshot, “o” meaning origin for the original logical volume copied to the snapshot;
- w : for writeable meaning that your snapshot has read and write permissions on it;
- i : for “inherited”;
- a : for “allocated”, meaning that actual space is dedicated to this logical volume;
- o : (in the sixth field) meaning “open” stating that the logical volume is mounted;
- s : snapshot target type for both logical volumes

Now that your **snapshot logical volume** is created, you will have to mount it in order to perform a backup of the filesystem.

## Mounting LVM snapshot using mount

In order to mount a LVM snapshot, you have to use the `mount` command, specify the full path to the logical volume and specify the mount point to be used.<br>
To achieve that, we would run the following command :

```bash
mkdir data_snapshot

mount /dev/vg-ssd/20240222_sdb1_snapshot /data_snapshot

lsblk
```

![lsblk-snapshot](lsblk-snapshot.png)

## Restoring LVM Snapshots

First remove the created files

![remove-files](remove-files.png)

Now that your LVM is backed up, you will be able to restore it on your local system.

In order to restore a LVM logical volume, you have to use the `lvconvert` command with the `–mergesnapshot` option and specify the name of the logical volume snapshot.

When using the `-–mergesnapshot`, the snapshot is merged into the original logical volume and is deleted right after it.

```bash
lvconvert --mergesnapshot /dev/vg-ssd/20240222_sdb1_snapshot

lvchange --refresh vg-ssd/lvdisk22
```

![lvconvert](lvconvert.png)

Now to see your files restored from the snapshot first run `reboot` command, and then `ls /data_sdb1`

![restored-files](restored-files.png)

Be happy that you have the files that you have lost :)

## Source of content

[devconnected](https://devconnected.com/lvm-snapshots-backup-and-restore-on-linux/#:~:text=The%20easiest%20way%20to%20backup,to%20specify%20a%20destination%20file.&text=When%20running%20this%20command%2C%20a,in%20your%20current%20working%20directory.) <br>
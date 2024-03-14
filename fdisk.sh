#!/bin/bash

# script name: fdisk
# Author: Sanaz Sadr
# date: 2024-03-05
# version: 1.0
# description: script for automating fdisk

now(){
    date "+%Y-%m-%d--%H:%M:%S"
}

log(){
    echo -e "`now` $@"
}

read -p "Enter your disk location: " disk
read -p "Enter your partition size (in Gb): " user_size

# remove alphabet from size
pure_size=`echo $user_size | tr -d [:alpha:]`

if [ -b "$disk" ]; then
    disk_size=`lsblk -dn -o SIZE $disk | tr -d [:alpha:]`
    
    if [ $pure_size -gt $disk_size ]; then
        log "Entered size $pure_size Gb is more than $disk_size Gb"
    elif [ $pure_size -lt 0 ]; then
        log "Entered size $pure_size Gb is less than zero"
    else
        echo -e "n\n\n\n\n+${pure_size}Gb\nw\nq" | fdisk "$disk"
    fi
else
    log "Disk $disk not found!"
fi


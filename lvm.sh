#!/bin/bash

# script name: lvm
# Author: Sanaz Sadr
# date: 2024-03
# version: 1.0
# description: script for automating lvm

now(){
    date "+%Y-%m-%d--%H:%M:%S"
}

log(){
    echo -e "`now` $@"
}

pv_create(){
    if [ -b "$pv_loc" ]; then
        pvcreate $pv_loc
        log "physical volume created"
        echo `pvscan | grep "$pv_loc"`

        read -p "Enter volume group name: " vg_name
        vg_create
    else
        log "physical volume location ($pv_loc) not found!"
    fi
}

vg_create(){
    duplicate_vg_name=`vgs | grep "$vg_name"`

    if [ -z $duplicate_vg_name ]; then
        vgcreate $vg_name $pv_loc
        log "volume group created"
        echo `vgs | grep "$vg_name"`

        read -p "Enter logical volume name: " lv_name
        read -p "Enter logical volume size (in Gb): " lv_size
        lv_create
    else
        log "Duplicate volume group name, $vg_name"
    fi
}

lv_create(){
    pure_lv_size=`echo $lv_size | tr -d [:alpha:]`
    pv_size=`lsblk -dn -o SIZE $pv_loc | tr -d [:alpha:]`

    duplicate_lv_name=`lvs | grep "$lv_name"`

    if [ -z $duplicate_lv_name ]; then
        if [ $pure_lv_size -gt $pv_size ]; then
            log "Entered size ($pure_lv_size) is more than $pv_size Gb"
        elif [ $pure_lv_size -lt 0 ]; then
            log "Entered size ($pure_lv_size) is less than zero"
        fi
        lvcreate --name $lv_name --size "$pure_lv_size"G $vg_name
        log "logical volume created"
        echo `lvs | grep "$lv_name"`
    else
        log "Duplicate logical volume name, $lv_name"
    fi
}

read -p "Enter physical volume location: " pv_loc

pv_create
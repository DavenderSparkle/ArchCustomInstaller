#!/bin/bash

BIOS=$1
isCorrect=""

cfdisk
## Manually Partition Disk
while [ -z $isCorrect ];
do
    echo "Are the partitions correct (y/n)"
    read isCorrect
    case $isCorrect in
    y|Y)
        ;;
    n|N)
        echo "Reopening cfdisk to fix partitions"
        cfdisk
        isCorrect=""
        ;;
    *)  
        echo "Invalid parameter"
        isCorrect=""
        ;;
    esac
done

## Ask User what kind of bios

if [ -z $BIOS ];
then
    BIOS=0
fi
while [ $BIOS -ne 1 ] && [ $BIOS -ne 2 ];
do
    echo "Is your BIOS Legacy or UEFI?"
    echo "1) Legacy" 
    echo "2) UEFI"
    read BIOS
done

## Formatting Disk
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon
case $BIOS in
1)
    ## Legacy
    mkfs.ext4 /dev/sda4;;
2)
    ## UEFI
    mkfs.ext4 /dev/sda3;;
*)
    echo "MKFS: Something went really wrong";;
esac

## Mounting Disks
case $BIOS in
1)
    ## Legacy
    mount /dev/sda4 /mnt
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot
    ;;
2)
    ## UEFI
    mount /dev/sda3 /mnt
    mkdir -p /mnt/boot/efi
    mount /dev/sda1 /mnt/boot/efi
    ;;
*)
    echo "MOUNT: Something went really wrong";;
esac
mkdir /mnt/etc
genfstab -U /mnt >> /mnt/etc/fstab

## Safeguard ArchCustomInstaller so there is no need to clone again
mkdir /mnt/ArchCustomInstaller
mount --bind /root/ArchCustomInstaller /mnt/ArchCustomInstaller

## Install Packages
pacstrap /mnt linux linux-firmware networkmanager wpa_supplicant base base-devel
## Entering chroot
arch-chroot /mnt
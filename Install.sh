#!/bin/bash

## Manually Partition Disk
cfdisk

## Ask User what kind of bios
BIOS=0
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
    echo "Something went really wrong";;
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
    echo "Something went really wrong";;
esac
mkdir /mnt/etc
genfstab -U /mnt >> /mnt/etc/fstab

## Install Packages
pacstrap /mnt linux linux-firmware networkmanager wpa_supplicant base base-devel
## Entering chroot
arch-chroot /mnt
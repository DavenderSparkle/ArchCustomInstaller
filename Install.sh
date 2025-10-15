#!/bin/bash

# Manually Partition Disk
cfdisk

# Formatting Disk
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon
mkfs.ext /dev/sda4

# Mounting Disks
mount /dev/sda4 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
mkdir /mnt/etc
genfstab -U /mnt >> /mnt/etc/fstab

# Install Packages
pacstrap /mnt linux linux-firmware networkmanager wpa_supplicant base base-devel
# Entering chroot
arch-chroot /mnt
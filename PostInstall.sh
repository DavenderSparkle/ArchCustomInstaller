#!/bin/bash

USERNAME=$1
LANG=$2
HOST=$3

## Change Root Pasword
passwd

## Create User
useradd -m $USERNAME
passwd $USERNAME
usermod -aG wheel $USERNAME

## Install editors
pacman -S vim nano

## Edit sudoers (uncomment # %wheel)
nano /etc/sudoers
## Edit Locale (uncomment your lang ex: #en_US.UTF8)
nano /etc/locale.gen
locale-gen
echo KEYMAP=$LANG >> /etc/vconsole.conf

## Create GRUB
pacman -S grub dosfstools os-prober  mtools
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

## HostName
echo $HOST >> /etc/hostname
echo 127.0.0.1 $HOST.localhost >> /etc/hosts

## Daemons
pacman -S networkmanager net-tools netctl openssh
systemctl enable NetworkManager.service
systemctl enable wpa_supplicant
systemctl enable sshd

## TODO: Selector, so it works with BOTH Legacy and UEFI BIOS
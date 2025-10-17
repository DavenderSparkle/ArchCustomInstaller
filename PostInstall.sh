#!/bin/bash

USERNAME=$1
LANG=$2
HOST=$3
BIOS=$4

## Check if parameters are correct
### Checking Language
if [ -n $LANG ];
then
    LANG="${LANG,,}"
    if [[ ! "$LANG" =~ ^[a-z]{2}$ ]];
    then
        echo "invalid lang code"
        LANG=""  
    fi
fi
### Checking HostName
if [ -n $HOST ];
then
    if [[ ! "$HOST" =~ ^[a-zA-Z0-9_-]+$ ]];
    then
        echo "Invalid Hostname, spaces not allowed"
        HOST=""
    fi
fi

## If User does not add parameters when executing command
while [ -z $USERNAME ] || [ -z $LANG ] || [ -z $HOST ];
do
    if [ -z $USERNAME ];
    then
        echo "Provide a username for the user to be created:"
        read USERNAME
    fi
    if [ -z $LANG ];
    then
        echo "Enter the language code for the system (e.g. us)"
        read LANG
        LANG="${LANG,,}"
        if [[ ! "$LANG" =~ ^[a-z]{2}$ ]];
        then
            echo "invalid lang code"
            LANG=""  
        fi
    fi
    if [ -z $HOST ];
    then
        echo "Enter a hostname for your machine"
        read HOST
        if [[ ! "$HOST" =~ ^[a-zA-Z0-9_-]+$ ]];
        then
            echo "Invalid Hostname, spaces not allowed"
            HOST=""
        fi
    fi
done

## Change Root Pasword
echo "Provide a password for root:"
passwd

## Create User
useradd -m $USERNAME
echo "Provide a password for $USERNAME:"
passwd $USERNAME
usermod -aG wheel $USERNAME

## Install editors
pacman -S vim nano

## Edit sudoers (uncomment: # %wheel)
nano /etc/sudoers
## Edit Locale (uncomment your lang: e.g.: #en_US.UTF8)
nano /etc/locale.gen
locale-gen
echo KEYMAP=$LANG >> /etc/vconsole.conf

## Ask User what kind of BIOS
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

## Create GRUB
pacman -S grub dosfstools os-prober mtools
case $BIOS in
1)
    ## Legacy
    grub-install /dev/sda
    ;;
2)
    pacman -S efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    ;;
*)
    echo "GRUB: Something went really wrong";;
esac
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
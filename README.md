# Arch Semi-Auto Installation Scripts

These scripts were created for personal use to automate the process of manually installing Arch Linux on both virtual and physical machines.
While I'm aware that the `archinstall` tool can provide a fully automated installation, it does not align with my preferences. Manualy installation offers control and customizacion over the process.

To be honest, the main reason I prefer manual instalallation over `archinstall` is that the first time I tried it, didn't install few key components and left VM without internet connection.

## How to use
> [!IMPORTANT]
> This scripts are currently intended for SATA drives, feel free to modify them to modify them to match NVME/VDB format acording to your needs  
> Soon (or later) I'll try to modify it to support more drive types

### Booting ArchLinux.iso
By default, the Arch Linux environment does not come with Git installed. To install it, run:
```
pacman -Sy git
```

Once Git is installed, clone this repository:
```
git clone https://github.com/DavenderSparkle/ArchCustomInstaller
```

### Installation (Install.sh)

1. Execute  
```
./Install.sh <bios>
``` 
If parameter is not provided, it will be requested later
>  `<bios>`: The kind of bios our system uses: 1) Legacy 2) UEFI

2. Partition the disk as you like, usually it looks like this depending on the BIOS type:

| Name          | Size   | Legacy                        | UEFI                                 |
| ------------- |--------|-------------------------------|--------------------------------------|
| /dev/sda1     | 512M   | Linux Filesystem              | EFI System                           |
| /dev/sda2     | 4.2G   | Linux Swap                    | Linux Swap                           |
| /dev/sda3     | 1M     | Bios Boot (Only if GPT Table) | -                                    |
| /dev/sda4     | Rest   | Linux Filesystem              | Linux Filesystem (becomes /dev/sda3) |

3. Hit `write` and type `yes`
4. Choose your BIOS type: 1) Legacy 2) UEFI
5. Afterwards, scripts takes care of:
    * Formatting the created partitions
    * Mounting the disks on their respective mount points
    * Install necesary packages
    * Enter `arch-chroot`


### Post Installation (PostInstall.sh)

After entering `arch-chroot` you need to `cd /ArchCustomInstaller`  
Run the following command:

```
./PostInstall.sh <username> <language> <hostname> <bios>
```
If parameters are not provided or are incorrect, they will be requested later  
###### Parameters:
>  `<username>`: The name of the user fot the operating system  
>  `<language>`: The preferred language for the system environment (e.g: us, es)  
>  `<hostname>`: The hostname you wish to assign to your system  
>  `<bios>`: The kind of bios our system uses: 1) Legacy 2) UEFI

Order of Execution:
1. **Automatic user creation**: The user will be created with a home directory and added to `%wheel` group for `sudo` access
2. **Set user password**: You will be prompted to manually set a password for the newly created user
3. **Automatic instalattion of** `vim` **and** `nano`
4. **Configure** `sudoers` **file**: The `/etc/sudoers` file will open in`nano` so you can manually uncomment `# %wheel` line to grand `sudo` access to users in the `%wheel` group
5. The `/etc/locale.gen` file will open in `nano` so you can manually uncomment you preferred language  
>(e.g., #es_ES.UTF-8)
6. **Console Configuration**: The script will automatically add the selected `<language>` to `/etc/vconsole.conf`  
>  (e.g., `KEYMAP=es` for Spanish) 
7. **Set hostname**: The hostname will be changed and updated in the `/etc/hosts` file
8. **Install and enable network packages**: `networkmanager`, `net-tools`, `netctl` and `openssh`
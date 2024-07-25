#!/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: Gagal Menginstall XFCE di termux."
    echo "Silakan lihat pesan kesalahan di atas"
  fi
}

trap finish EXIT

username="$1"

pkgs_proot=('sudo' 'wget' 'jq' 'flameshot' 'conky-all')

#Install Debian proot
pd install debian
pd login debian --shared-tmp -- env DISPLAY=:0 apt update
pd login debian --shared-tmp -- env DISPLAY=:0 apt upgrade -y
pd login debian --shared-tmp -- env DISPLAY=:0 apt install "${pkgs_proot[@]}" -y -o Dpkg::Options::="--force-confold"

#Create user
pd login debian --shared-tmp -- env DISPLAY=:0 groupadd storage
pd login debian --shared-tmp -- env DISPLAY=:0 groupadd wheel
pd login debian --shared-tmp -- env DISPLAY=:0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"

#Add user to sudoers
chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w  $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

#Set proot aliases
echo "
alias ls='eza -lF --icons'
alias cat='bat '
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc


#Setup Hardware Acceleration
pd login debian --shared-tmp -- env DISPLAY=:0 wget https://github.com/phoenixbyrd/Termux_XFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
pd login debian --shared-tmp -- env DISPLAY=:0 sudo apt install -y ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb

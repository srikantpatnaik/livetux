#!/bin/bash

# Variables and paths
rootfs=/mnt/rootfs
mkdir -p $rootfs
raw_file=e18_13-10_i386.raw
core_image_url='http://cdimage.ubuntu.com/ubuntu-core/releases/13.10/release/ubuntu-core-13.10-core-i386.tar.gz'


dd if=/dev/zero of=$raw_file bs=1M count=1000

(echo n; echo p; echo ''; echo ''; echo ''; echo 'a'; echo '1';echo w) | fdisk $raw_file

free_loop_device=$(losetup -f --show $raw_file | cut -d '/' -f 3)

echo $free_loop_device

kpartx -a /dev/$free_loop_device

dd if=/usr/lib/extlinux/mbr.bin conv=notrunc bs=440 count=1 of=/dev/$free_loop_device

mkfs.ext4 /dev/mapper/$(echo $free_loop_device)p1 

mount -o loop /dev/mapper/$(echo $free_loop_device)p1 $rootfs

# Download the 13.10 i386 core image or any other image in future

wget -c $core_image_url -O core.tar.gz

tar -C $rootfs -xzphf core.tar.gz

cp /etc/apt/sources.list $rootfs/etc/apt/sources.list
cp /etc/resolv.conf $rootfs/etc/resolv.conf

sync

function mnt() {
    echo "MOUNTING"
    mount -t proc /proc $rootfs/proc
    mount -t sysfs /sys $rootfs/sys
    mount -o bind /dev $rootfs/dev
    mount -o bind /dev/pts $rootfs/dev/pts
}

function umnt() {
    echo "UNMOUNTING"
    umount $rootfs/proc
    umount $rootfs/sys
    umount $rootfs/dev/pts
    umount $rootfs/dev
}

mnt
chroot  $rootfs /bin/bash -c "apt-get update && apt-get install -y language-pack-en-base vim.tiny sudo ssh net-tools ethtool wireless-tools iputils-ping alsa-utils linux-{headers,image}-generic e17 xorg wicd-cli feh mupdf leafpad initramfs-tools casper"
# remove xorg from apt-get list, add nameserver 10.101.1.5 in /etc/resolv.conf
chroot $rootfs /bin/bash -c "adduser workshop && addgroup workshop adm && addgroup workshop sudo && addgroup workshop audio"

chroot $rootfs /bin/bash -c "apt-get clean" 

chroot $rootfs /bin/bash -c "mv /boot/vmlinuz* /boot/vmlinuz" 
chroot $rootfs /bin/bash -c "mv /boot/initrd* /boot/initrd.lz" 

extlinux --install $rootfs/boot

echo "
PROMPT 0
TIMEOUT 1
DEFAULT core

LABEL core
        LINUX /boot/vmlinuz
        APPEND root=/dev/sda1 ro
        INITRD /boot/initrd.lz" > $rootfs/boot/extlinux.conf

sync


umnt
umount $rootfs

kpartx -d /dev/$free_loop_device

losetup -d /dev/$free_loop_device

kvm-spice $raw_file

# TODO
# add squashfs tools and grubrescue

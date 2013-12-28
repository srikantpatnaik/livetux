#dd if=/usr/lib/extlinux/mbr.bin of=e18 bs=512 count=1
#!/bin/bash

# Variables and paths
rootfs=/mnt/rootfs
mkdir -p $rootfs
raw_file=e18_13-10_i386.raw


dd if=/dev/zero of=$raw_file bs=1M count=1000 

(echo n; echo p; echo ''; echo ''; echo ''; echo 'a'; echo '1';echo w) | fdisk $raw_file

free_loop_device=$(losetup -f --show $raw_file | cut -d '/' -f 3)

echo $free_loop_device

kpartx -a /dev/$free_loop_device

dd if=/usr/lib/extlinux/mbr.bin conv=notrunc bs=440 count=1 of=/dev/$free_loop_device

mkfs.ext4 /dev/mapper/$(echo $free_loop_device)p1 

mount -o loop /dev/mapper/$(echo $free_loop_device)p1 $rootfs

cp -ax /media/srikant/1d35977a-528d-4c76-b01f-b5ee16fe998b/* $rootfs

extlinux --install $rootfs/boot

sync

umount $rootfs

kpartx -d /dev/$free_loop_device

losetup -d /dev/$free_loop_device

qemu $raw_file


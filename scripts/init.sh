#!/bin/bash

set -e

sh $LFS/tools/versionVerify.sh #> /logs/verification.log

# 1. Switch to lfs user


# Docker assumes the lfs user, .bashrc will be loaded as this is a non login shell


# 2. Build & Install required libraries (Chapter 5-6)
sh $LFS/tools/build.sh


# 3. Continue as root

exec sudo -E -u root /bin/sh - <<EOF

# change ownership of $LFS dir
sudo chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in  x86_64) sudo chown -R root:root $LFS/lib64 ;;esac


# 4. Prepare VKFS (Virtual Kernel File System)

# Dirs where the FS will be mounted
mkdir -pv $LFS/{dev,proc,sys,run}

mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3


mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi


# 5. Enter chroot env


chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    MAKEFLAGS="$MAKEFLAGS"      \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h\
    -c "/tools/chrootCommands.sh"

# Unmount VKFS

umount $LFS/dev{/pts,}
umount $LFS/{sys,proc,run}


# Strip debugging symbols from executables & libraries

strip --strip-debug $LFS/usr/lib/*
strip --strip-unneeded $LFS/usr/{,s}bin/*
strip --strip-unneeded $LFS/tools/bin/*

# Create a backup of the temporary tools

cd $LFS && tar -cJpf $HOME/lfs-temp-tools-10.1.tar.xz .

# To restore run
# cd $LFS && rm -rf ./* && tar -xpf $HOME/lfs-temp-tools-10.1.tar.xz

# 999. Mount dir & create image
#sh ./scripts/createDisk.sh > /logs/createDisk.log
EOF




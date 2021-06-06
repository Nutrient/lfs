#!/bin/bash

# All scripts are mapped into the docker instance inside the $LFS/tools folder
# All libraries are mapped into the $LFS/sources folder
# Inside the chroot environment $LFS/* becomes /

# Exit if a command returns a non-zero status
set -e

# 1. Verify requirements

sh $LFS/tools/versionVerify.sh > $LFS/logs/system-requirements

# 2. Build Cross Toolchain & Temporary tools
# Docker assumes the lfs user, .bashrc will be loaded as this is a non login shell

sh $LFS/tools/build-cross-toolchain.sh

# All the remaining commands must be run as root

exec sudo -E -u root /bin/sh - <<EOF

# Change ownership of $LFS to root
chown -vR root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
x86_64)
    chown -vR root:root $LFS/lib64
    ;;
esac

# 4. Mount VKFS (Virtual Kernel File System)

# Create dirs where the FS will be mounted

mkdir -pv $LFS/{dev,proc,sys,run}

mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3

mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

# Some host systems use /dev/shm as a sym link to /run/shm
# /run was mounted above so create dir if sym link exists
if [ -h $LFS/dev/shm ]; then
    mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

# 5. Enter chroot env & build additional temporary tools

chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    MAKEFLAGS="$MAKEFLAGS" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h -c "sh /tools/chrootCommands.sh"

# 6. Unmount VKFS to strip symbols & create backup (if enabled)

umount $LFS/dev{/pts,}
umount $LFS/{sys,proc,run}

# Strip debugging symbols from executables & libraries

strip --strip-debug $LFS/usr/lib/* >$LFS/logs/strip 2>&1
strip --strip-unneeded $LFS/usr/{,s}bin/* >>$LFS/logs/strip 2>&1
strip --strip-unneeded $LFS/tools/bin/* >>$LFS/logs/strip 2>&1

# Create a backup of the temporary tools

if [ $XTOOLCHAIN_BACKUP -eq 1 ]; then
    (cd $LFS && tar --exclude='./output' --exclude='./tools/*.sh' -cJpf $LFS/output/lfs-temp-tools-10.1.tar.xz .)
fi


# Mount VKFS Again

mount -v --bind /dev $LFS/dev
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

# 7. Build LFS system

chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    MAKEFLAGS="$MAKEFLAGS" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h -c "sh /tools/chrootCommands-2.sh"

# 8. Configure the LFS system with hasing enabled

chroot "$LFS" /usr/bin/env -i \
    HOME=/root \
    TERM="$TERM" \
    PS1='(lfs chroot) \u:\w\$ ' \
    MAKEFLAGS="$MAKEFLAGS" \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login \
    -c "sh /tools/chrootCommands-3.sh"

# Unmount VKFS

umount -v $LFS/dev{/pts,}
umount -v $LFS/{sys,proc,run}
umount -v $LFS

# Create final backup

if [ $LFS_BACKUP -eq 1 ]; then
    (cd $LFS && tar --exclude='./output' --exclude='./tools/*.sh' -cJpf $LFS/output/lfs-final-10.1.tar.xz .)
fi

# 999. Mount dir & create image
sh $LFS/tools/createDisk.sh > $LFS/logs/createDisk
EOF

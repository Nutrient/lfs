#!/bin/bash
set -e

RAMDISK=$(pwd)/ramdisk
LOOP_DIR=$(pwd)$LOOP



# Create loop device if it does not exist (Block system)
[ -e $LOOP ] || mknod $LOOP b 7 0

# ensure loop directory
[ -d $LOOP_DIR ] || mkdir -pv $LOOP_DIR

# create iso img
dd if=/dev/zero of=$RAMDISK bs=1k count=$IMAGE_SIZE

echo "Plugging off VFS from loop device..."
# plug off any virtual fs from loop device
losetup -d $LOOP || true

echo "Associate loop device with dir"
# associate it with ${LOOP}
losetup $LOOP $RAMDISK

# Create EXT4 file system
mkfs -t ext4 $RAMDISK

mount -o loop $LOOP $LOOP_DIR




echo $(losetup -l)
echo $(df -h)
echo $(fdisk -l)
echo $(ls $PWD)
#!/bin/bash
set -e

RAMDISK=$(pwd)/ramdisk
LOOP_DIR=$(pwd)$LOOP



# Create loop device if it does not exist (Block system)
[ -e $LOOP ] || mknod $LOOP b 7 0

# ensure loop directory
[ -d $LOOP_DIR ] || mkdir -pv $LOOP_DIR

# make sure that the env is clean
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
rm -rf $LOOP_DIR/lost+found



# this sections builds the final image
#pushd $INITRD_TREE
#cp -dpR $(ls -A | grep -Ev "sources|tools") $LOOP_DIR
#popd

# show statistics
#df $LOOP_DIR

#echo "Compressing system ramdisk image.."
#bzip2 -c $RAMDISK > $IMAGE

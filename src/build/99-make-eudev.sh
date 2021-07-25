#!/bin/bash
set -e

tar -xf eudev-*.tar.gz
pushd eudev-*/

./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static

make
mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi
make install
tar -xvf ../udev-lfs-20171102.tar.xz
make -f udev-lfs-20171102/Makefile.lfs install
udevadm hwdb --update

popd
rm -rf eudev-*/

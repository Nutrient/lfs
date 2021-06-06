#!/bin/bash
set -e

tar -xf util-linux-*.tar.xz
pushd util-linux-*/

mkdir -pv /var/lib/hwclock

./configure                                 \
  ADJTIME_PATH=/var/lib/hwclock/adjtime     \
  --docdir=/usr/share/doc/util-linux-2.36.2 \
  --disable-chfn-chsh                       \
  --disable-login                           \
  --disable-nologin                         \
  --disable-su                              \
  --disable-setpriv                         \
  --disable-runuser                         \
  --disable-pylibmount                      \
  --disable-static                          \
  --without-python                          \
  runstatedir=/run

make
make install

popd

# Clean up
rm -rf util-linux-*/

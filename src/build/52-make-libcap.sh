#!/bin/bash
set -e

tar -xf libcap-*.tar.xz
pushd libcap-*/

sed -i '/install -m.*STA/d' libcap/Makefile
make prefix=/usr lib=lib

if [ $LFS_TEST -eq 1 ]; then
  make test || true
fi

make prefix=/usr lib=lib install

for libname in cap psx; do
  mv -v /usr/lib/lib${libname}.so.* /lib
  ln -sfv ../../lib/lib${libname}.so.2 /usr/lib/lib${libname}.so
  chmod -v 755 /lib/lib${libname}.so.2.48
done

popd

rm -rf libcap-*/

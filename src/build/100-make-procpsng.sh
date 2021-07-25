#!/bin/bash
set -e

tar -xf procps-*.tar.xz
pushd procps-*/

./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.17 \
            --disable-static                         \
            --disable-kill

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
mv -v /usr/lib/libprocps.so.* /lib

ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

popd
rm -rf procps-*/

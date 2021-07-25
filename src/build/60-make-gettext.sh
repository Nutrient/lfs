#!/bin/bash
set -e

tar -xf gettext-*.tar.xz
pushd gettext-*/

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

popd
rm -rf gettext-*/

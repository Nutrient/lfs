#!/bin/bash
set -e

tar -xf intltool-*.tar.gz

pushd intltool-*/

sed -i 's:\\\${:\\\$\\{:' intltool-update.in

./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

popd
rm -rf intltool-*/

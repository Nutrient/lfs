#!/bin/bash
set -e
tar -xf gdbm-*.tar.gz

pushd gdbm-*/
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf gdbm-*/

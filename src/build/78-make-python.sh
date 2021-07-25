#!/bin/bash
set -e

tar -xf Python-*.tar.xz
pushd Python-*/

./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes

make

if [ $LFS_TEST -eq 1 ]; then
  # Tests in python in this stage cause the process to stall indefinetely
  #make test || true
fi

make install
install -v -dm755 /usr/share/doc/python-3.9.2/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.9.2/html \
    -xvf ../python-3.9.2-docs-html.tar.bz2

popd
rm -rf Python-*/

#!/bin/bash
set -e

tar -xf bash-*.tar.gz
pushd bash-*/

./configure                       \
  --prefix=/usr                   \
  --build=$(support/config.guess) \
  --host=$LFS_TGT                 \
  --without-bash-malloc

make
make DESTDIR=$LFS install
mv $LFS/usr/bin/bash $LFS/bin/bash
ln -sv bash $LFS/bin/sh

popd

# Clean up
rm -rf bash-*/

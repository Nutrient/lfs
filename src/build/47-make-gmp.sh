#!/bin/bash
set -e

tar -xf gmp-*.tar.xz
pushd gmp-*/

./configure --prefix=/usr \
  --enable-cxx            \
  --disable-static        \
  --docdir=/usr/share/doc/gmp-6.2.1

make
make html

if [ $LFS_TEST -eq 1 ]; then
  make check 2>&1 | tee gmp-check-log
  awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
fi

make install
make install-html

popd
rm -rf gmp-*/

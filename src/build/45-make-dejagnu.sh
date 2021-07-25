#!/bin/bash
set -e

tar -xf dejagnu-*.tar.gz
pushd dejagnu-*/

./configure --prefix=/usr

makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi
makeinfo --plaintext -o doc/dejagnu.txt doc/dejagnu.texi

make install

install -v -dm755 /usr/share/doc/dejagnu-1.6.2
install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

popd
rm -rf dejagnu-*/

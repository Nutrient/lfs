#!/bin/bash
set -e

tar -xf XML-Parser-*.tar.gz

pushd XML-*/

perl Makefile.PL

make

if [ $LFS_TEST -eq 1 ]; then
  make test || true
fi

make install

popd
rm -rf XML-*/

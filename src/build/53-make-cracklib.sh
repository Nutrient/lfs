#!/bin/bash
set -e

tar -xjf cracklib-*.tar.bz2
pushd cracklib-*/

sed -i '/skipping/d' util/packer.c
./configure --prefix=/usr \
  --disable-static        \
  --with-default-dict=/lib/cracklib/pw_dict

make
make install

mv -v /usr/lib/libcrack.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so

install -v -m644 -D ../cracklib-words-2.9.7.bz2 \
                    /usr/share/dict/cracklib-words.bz2

bunzip2 -v /usr/share/dict/cracklib-words.bz2

ln -v -sf cracklib-words /usr/share/dict/words

echo $(hostname) >>/usr/share/dict/cracklib-extra-words

install -v -m755 -d /lib/cracklib

create-cracklib-dict  /usr/share/dict/cracklib-words \
                      /usr/share/dict/cracklib-extra-words

if [ $LFS_TEST -eq 1 ]; then
  make test || true
fi

popd
rm -rf cracklib-*/

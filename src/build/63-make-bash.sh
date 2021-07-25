#!/bin/bash
set -e

tar -xf bash-*.tar.gz
pushd bash-*/

sed -i  '/^bashline.o:.*shmbchar.h/a bashline.o: ${DEFDIR}/builtext.h' Makefile.in

./configure --prefix=/usr                    \
            --docdir=/usr/share/doc/bash-5.1 \
            --without-bash-malloc            \
            --with-installed-readline

make

if [ $LFS_TEST -eq 1 ]; then
  chown -Rv tester .
  su tester << EOF
PATH=$PATH make tests < $(tty)
EOF
fi


make install
mv -vf /usr/bin/bash /bin

popd
rm -rf bash-*/

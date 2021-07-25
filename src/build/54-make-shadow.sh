#!/bin/bash
set -e

tar -xf shadow-*.tar.xz
pushd shadow-*/

sed -i 's/groups$(EXEEXT) //' src/Makefile.in

find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -i etc/login.defs
sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs
sed -i 's/1000/999/' etc/useradd

touch /usr/bin/passwd

./configure --sysconfdir=/etc \
            --with-libcrack   \
            --with-group-name-max-length=32
make
make install

pwconv && grpconv
sed -i 's/yes/no/' /etc/default/useradd

popd
rm -rf shadow-*/

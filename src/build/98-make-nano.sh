#!/bin/bash
set -e

tar -xf nano-*.tar.xz
pushd nano-*/

./configure --prefix=/usr     \
            --sysconfdir=/etc \
            --enable-utf8     \
            --docdir=/usr/share/doc/nano-5.6

make
make install
install -v -m644 doc/{nano.html,sample.nanorc} /usr/share/doc/nano-5.6

cat > /etc/nanorc << "EOF"
set autoindent
set constantshow
set fill 72
set historylog
set multibuffer
set positionlog
set quickblank
set regexp
set suspend
EOF

popd
rm -rf nano-*/

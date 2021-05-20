#!/bin/bash


# Install man pages

( cd sources && tar -xf man-pages-*.tar.xz && cd man-pages-*/ &&    \
time { make install; } ) > /logs/man-pages 2>&1 && rm -rf sources/man-pages-*/

# Install iana-etc

( cd sources && tar -xf iana-etc-*.tar.gz && cd iana-etc-*/ &&    \
cp services protocols /etc) && rm -rf sources/iana-etc

# Install glibc 2 && locales

( cd sources && tar -xf glibc-*.tar.xz && cd glibc-*/ &&  \
patch -Np1 -i ../glibc-*-fhs-1.patch &&     \
sed -e '402a\      *result = local->data.services[database_index];' \
    -i nss/nss_database.c &&            \
mkdir -v build && cd build &&           \
time {  ../configure                    \
        --prefix=/usr                   \
        --disable-werror                \
        --enable-kernel=3.2             \
        --enable-stack-protector=strong \
        --with-headers=/usr/include     \
        libc_cv_slibdir=/lib && make && make check && \
        touch /etc/ld.so.conf && \
        sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile &&\
        make install && \
        cp -v ../nscd/nscd.conf /etc/nscd.conf &&\
        mkdir -pv /var/cache/nscd && \
        mkdir -pv /usr/lib/locale && \
        localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true && \
        localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8 && \
        localedef -i de_DE -f ISO-8859-1 de_DE && \
        localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro && \
        localedef -i de_DE -f UTF-8 de_DE.UTF-8 && \
        localedef -i el_GR -f ISO-8859-7 el_GR && \
        localedef -i en_GB -f UTF-8 en_GB.UTF-8 && \
        localedef -i en_HK -f ISO-8859-1 en_HK && \
        localedef -i en_PH -f ISO-8859-1 en_PH && \
        localedef -i en_US -f ISO-8859-1 en_US && \
        localedef -i en_US -f UTF-8 en_US.UTF-8 && \
        localedef -i es_MX -f ISO-8859-1 es_MX && \
        localedef -i fa_IR -f UTF-8 fa_IR && \
        localedef -i fr_FR -f ISO-8859-1 fr_FR && \
        localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro && \
        localedef -i fr_FR -f UTF-8 fr_FR.UTF-8 && \
        localedef -i it_IT -f ISO-8859-1 it_IT && \
        localedef -i it_IT -f UTF-8 it_IT.UTF-8 && \
        localedef -i ja_JP -f EUC-JP ja_JP && \
        localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true && \
        localedef -i ja_JP -f UTF-8 ja_JP.UTF-8 && \
        localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R && \
        localedef -i ru_RU -f UTF-8 ru_RU.UTF-8 && \
        localedef -i tr_TR -f UTF-8 tr_TR.UTF-8 && \
        localedef -i zh_CN -f GB18030 zh_CN.GB18030 && \
        localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS && \
# Configure glibc

# Add nsswitch.conf
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
# Add timezone data
tar -xf ../../tzdata2021a.tar.gz &&     \
ZONEINFO=/usr/share/zoneinfo &&         \
mkdir -pv $ZONEINFO/{posix,right} &&    \
for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward; do
    zic -L /dev/null   -d $ZONEINFO       ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
    zic -L leapseconds -d $ZONEINFO/right ${tz}
done && \
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO && \
zic -d $ZONEINFO -p America/New_York && \
unset ZONEINFO && \
ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime && \
cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF
cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
mkdir -pv /etc/ld.so.conf.d; } ) > /logs/glibc-2 2>&1 && \
rm -rf sources/glibc-*/

# Install zlib
( cd sources && tar -xf zlib-*.tar.xz && cd zlib-*/ &&    \
time {  ./configure     \
        --prefix=/usr   \
        && make && make check && make install && \
        mv -v /usr/lib/libz.so.* /lib && \
        ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so && \
        rm -fv /usr/lib/libz.a; } ) > /logs/zlib 2>&1 && \
rm -rf sources/zlib-*/

# Install bzip2
( cd sources && tar -xf bzip2-*.tar.gz && cd bzip2-*/   &&  \
time {  patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch       &&  \
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile     &&  \
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile   &&  \
make -f Makefile-libbz2_so                              &&  \
make clean                                              &&  \
make                                                    &&  \
make PREFIX=/usr install                                &&  \
cp -v bzip2-shared /bin/bzip2                           &&  \
cp -av libbz2.so* /lib                                  &&  \
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so       &&  \
rm -v /usr/bin/{bunzip2,bzcat,bzip2}                    &&  \
ln -sv bzip2 /bin/bunzip2                               &&  \
ln -sv bzip2 /bin/bzcat                                 &&  \
rm -fv /usr/lib/libbz2.a; } ) > /logs/bzip2 2>&1        &&  \
rm -rf sources/bzip2-*/

# Install xz

( cd sources && tar -xf xz-*.tar.xz && cd xz-*/   &&  \
time { ./configure          \
        --prefix=/usr       \
        --disable-static    \
        --docdir=/usr/share/doc/xz-5.2.5    &&  \
        make && make check && make install  &&  \
        mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin && \
        mv -v /usr/lib/liblzma.so.* /lib && \
        ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so; } ) > /logs/xz-2 2>&1 && \
rm -rf sources/xz-*/

# Install zstd

( cd sources && tar -xf zstd-*.tar.gz && cd zstd-*/     &&  \
make && make check && make prefix=/usr install          &&  \
rm -v /usr/lib/libzstd.a                                &&  \
mv -v /usr/lib/libzstd.so.* /lib                        &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so ) > /logs/zstd 2>&1 && \
rm -rf sources/zstd-*/

# Install file

( cd sources && tar -xf file-*.tar.gz && cd file-*/     &&  \
./configure --prefix=/usr                               &&  \
make && make check && make install ) > /logs/file-2 2>&1 && \
rm -rf sources/file-*/

# Install readline
( cd sources && tar -xf readline-*.tar.gz && cd readline-*/     &&  \
sed -i '/MV.*old/d' Makefile.in                                 &&  \
sed -i '/{OLDSUFF}/c:' support/shlib-install                    &&  \
./configure --prefix=/usr    \
            --disable-static \
            --with-curses    \
            --docdir=/usr/share/doc/readline-8.1                &&  \
make SHLIB_LIBS="-lncursesw"                                    &&  \
make SHLIB_LIBS="-lncursesw" install                            &&  \
mv -v /usr/lib/lib{readline,history}.so.* /lib                  &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so   &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so    &&  \
install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1 ) > /logs/readline 2>&1    &&  \
rm -rf sources/readline-*/

# Install m4
( cd sources && tar -xf m4-*.tar.xz && cd m4-*/     &&  \
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c     &&  \
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h  &&  \
./configure --prefix=/usr                               &&  \
make && make check && make install) > /logs/m4-2 2>&1   &&  \
rm -rf sources/m4-*/

# Install bc

( cd sources && tar -xf bc-*.tar.xz && cd bc-*/     &&  \
PREFIX=/usr CC=gcc ./configure.sh -G -O3            &&  \
make && make test && make install ) > /logs/bc 2>&1 &&  \
rm -rf sources/bc-*/

# Install flex
( cd sources && tar -xf flex-*.tar.gz && cd flex-*/     &&  \
./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static                            &&  \
make && make check && make install                      &&  \
ln -sv flex /usr/bin/lex ) > /logs/flex 2>&1            &&  \
rm -rf sources/flex-*/

# Install tcl
( cd sources && tar -xf tcl*-src.tar.gz && cd tcl*/     &&  \
tar -xf ../tcl8.6.11-html.tar.gz --strip-components=1         &&  \
SRCDIR=$(pwd)                                                 &&  \
cd unix                                                       &&  \
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)  &&  \
make                                                              &&  \
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh                                               &&  \
sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|"            \
    -i pkgs/tdbc1.1.2/tdbcConfig.sh                               &&  \
sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|"            \
    -i pkgs/itcl4.2.1/itclConfig.sh                               &&  \
unset SRCDIR                                                      &&  \
make test && make install                                         &&  \
chmod -v u+w /usr/lib/libtcl8.6.so                                &&  \
make install-private-headers                                      &&  \
ln -sfv tclsh8.6 /usr/bin/tclsh                                   &&  \
mv /usr/share/man/man3/{Thread,Tcl_Thread}.3 ) > /logs/tcl 2>&1   &&  \
rm -rf sources/tcl*/

# Install Expect
( cd sources && tar -xf expect*.tar.gz && cd expect*/     &&  \
./configure --prefix=/usr           \
            --with-tcl=/usr/lib     \
            --enable-shared         \
            --mandir=/usr/share/man \
            --with-tclinclude=/usr/include                &&  \
make && make test && make install                         &&  \
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib) > /logs/expect 2>&1 && \
rm -rf sources/expect*/

# Install DejaGNU
( cd sources && tar -xf dejagnu-*.tar.gz && cd dejagnu-*/         &&  \
./configure --prefix=/usr                                         &&  \
makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi   &&  \
makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi   &&  \
make install                                                      &&  \
install -v -dm755  /usr/share/doc/dejagnu-1.6.2                   &&  \
install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2  &&  \
make check ) > /logs/dejagnu 2>&1                                       && \
rm -rf sources/dejagnu-*/

# Install Binutils

( cd sources && tar -xf binutils-*.tar.xz && cd binutils-*/         &&  \
expect -c "spawn ls"                                                &&  \
sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in          &&  \
mkdir -v build                                                      &&  \
cd       build                                                      &&  \
../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib                                     &&  \
make tooldir=/usr                                                   &&  \
make -k check                                                       &&  \
make tooldir=/usr install                                           &&  \
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a) > /logs/binutils-3 2>&1 &&  \
rm -rf sources/binutils-*/

# Install gmp

( cd sources && tar -xf gmp-*.tar.xz && cd gmp-*/           &&  \
./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.2.1               &&  \
make && make html && make check 2>&1 | tee gmp-check-log    &&  \
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log &&  \
make install && make install-html ) > /logs/gmp 2>&1        &&  \
rm -rf sources/gmp-*/

# Install mpfr

( cd sources && tar -xf mpfr-*.tar.xz && cd mpfr-*/       &&  \
./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0            &&  \
make                                                      &&  \
make html                                                 &&  \
make check                                                &&  \
make install                                              &&  \
make install-html ) > /logs/mpfr 2>&1                     &&  \
rm -rf sources/mpfr-*/

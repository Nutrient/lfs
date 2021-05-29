#!/bin/bash


# Install man pages

( cd sources && tar -xf man-pages-*.tar.xz && cd man-pages-*/ &&    \
time { make install; } ) > /logs/man-pages 2>&1 && rm -rf sources/man-pages-*/

# Install iana-etc

( cd sources && tar -xf iana-etc-*.tar.gz && cd iana-etc-*/ &&    \
cp services protocols /etc) && rm -rf sources/iana-etc-*/

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

# Note: || true is used to the fact that make check returns 4 expected erros and halts
# execution

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
make -k check || true                                               &&  \
make tooldir=/usr install                                           &&  \
rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a) > /logs/binutils-3 2>&1 &&  \
rm -rf sources/binutils-*/

# Install gmp, review docs after for less capable processors

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

# Install mpc

( cd sources && tar -xf mpc-*.tar.gz && cd mpc-*/       &&  \
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1           &&  \
make && make html && make check && make install         &&  \
make install-html ) > /logs/mpc 2>&1                    &&  \
rm -rf sources/mpc-*/

# Install attr

( cd sources && tar -xf attr-*.tar.gz && cd attr-*/       &&  \
./configure --prefix=/usr     \
            --bindir=/bin     \
            --disable-static  \
            --sysconfdir=/etc \
            --docdir=/usr/share/doc/attr-2.4.48         &&  \
make && make check && make install                      &&  \
mv -v /usr/lib/libattr.so.* /lib                        &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so ) > /logs/attr 2>&1 &&  \
rm -rf sources/attr-*/

# Install acl
( cd sources && tar -xf acl-*.tar.gz && cd acl-*/       &&  \
./configure --prefix=/usr         \
            --bindir=/bin         \
            --disable-static      \
            --libexecdir=/usr/lib \
            --docdir=/usr/share/doc/acl-2.2.53          &&  \
make && make install && mv -v /usr/lib/libacl.so.* /lib &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so ) > /logs/acl 2>&1  &&  \
rm -rf sources/acl-*/

# Install libcap
( cd sources && tar -xf libcap-*.tar.xz && cd libcap-*/       &&  \
sed -i '/install -m.*STA/d' libcap/Makefile                   &&  \
make prefix=/usr lib=lib && make test                         &&  \
make prefix=/usr lib=lib install                              &&  \
for libname in cap psx; do
    mv -v /usr/lib/lib${libname}.so.* /lib
    ln -sfv ../../lib/lib${libname}.so.2 /usr/lib/lib${libname}.so
    chmod -v 755 /lib/lib${libname}.so.2.48
done ) > /logs/libcap 2>&1                                    &&  \
rm -rf sources/libcap-*/

# Install cracklib (beyond linux from scratch library)
( cd sources && tar -xjf cracklib-*.tar.bz2 && cd cracklib-*/       &&  \
sed -i '/skipping/d' util/packer.c                                  &&  \
./configure --prefix=/usr    \
            --disable-static \
            --with-default-dict=/lib/cracklib/pw_dict               &&  \
make && make install                                                &&  \
mv -v /usr/lib/libcrack.so.* /lib                                   &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libcrack.so) /usr/lib/libcrack.so &&  \
install -v -m644 -D    ../cracklib-words-2.9.7.bz2 \
                         /usr/share/dict/cracklib-words.bz2         &&  \
bunzip2 -v               /usr/share/dict/cracklib-words.bz2         &&  \
ln -v -sf cracklib-words /usr/share/dict/words                      &&  \
echo $(hostname) >>      /usr/share/dict/cracklib-extra-words       &&  \
install -v -m755 -d      /lib/cracklib                              &&  \
create-cracklib-dict     /usr/share/dict/cracklib-words \
                         /usr/share/dict/cracklib-extra-words       &&  \
make test ) > /logs/cracklib 2>&1                                   &&  \
rm -rf sources/cracklib-*/

# Install shadow, passwd will be set later?

( cd sources && tar -xf shadow-*.tar.xz && cd shadow-*/       &&  \
sed -i 's/groups$(EXEEXT) //' src/Makefile.in                 &&  \
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \; &&  \
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; &&  \
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; &&  \
sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
    -e 's:/var/spool/mail:/var/mail:'                 \
    -i etc/login.defs                                             &&  \
sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs &&  \
sed -i 's/1000/999/' etc/useradd                                  &&  \
touch /usr/bin/passwd                                             &&  \
./configure --sysconfdir=/etc \
            --with-libcrack   \
            --with-group-name-max-length=32                       &&  \
make && make install                                              &&  \
pwconv && grpconv                                                 &&  \
sed -i 's/yes/no/' /etc/default/useradd ) > /logs/shadow 2>&1     &&  \
rm -rf sources/shadow-*/

# Install gcc

( cd sources && tar -xf gcc-*.tar.xz && cd gcc-*/       &&  \
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac                                                    &&  \
mkdir -v build && cd build                              &&  \
../configure --prefix=/usr            \
             LD=ld                    \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib                         &&  \
make && ulimit -s 32768                                 &&  \
chown -Rv tester .                                      &&  \
su tester -c "PATH=$PATH make -k check || true"         &&  \
../contrib/test_summary                                 &&  \
make install                                            &&  \
rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/10.2.0/include-fixed/bits/  &&  \
chown -v -R root:root \
    /usr/lib/gcc/*linux-gnu/10.2.0/include{,-fixed}                 &&  \
ln -sv ../usr/bin/cpp /lib                                          &&  \
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/10.2.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/                                       &&  \
echo 'int main(){}' > dummy.c                                       &&  \
cc dummy.c -v -Wl,--verbose &> dummy.log                            &&  \
readelf -l a.out | grep ': /lib'                                    &&  \
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log                  &&  \
grep -B4 '^ /usr/include' dummy.log                                 &&  \
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'                  &&  \
grep "/lib.*/libc.so.6 " dummy.log                                  &&  \
grep found dummy.log                                                &&  \
rm -v dummy.c a.out dummy.log                                       &&  \
mkdir -pv /usr/share/gdb/auto-load/usr/lib                          &&  \
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib ) > /logs/gcc-3 2>&1  &&  \
rm -rf sources/gcc-*/

# Install pkg cfg
( cd sources && tar -xf pkg-config-*.tar.gz && cd pkg-config-*/       &&  \
./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2                 &&  \
make && make check && make install ) > /logs/pkg-confg 2>&1           &&  \
rm -rf sources/pkg-config-*/

# Install ncurses
( cd sources && tar -xf ncurses-*.tar.gz && cd ncurses-*/       &&  \
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec                                      &&  \
make && make install                                            &&  \
mv -v /usr/lib/libncursesw.so.6* /lib                           &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so &&  \
for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done                                                            &&  \
rm -vf                     /usr/lib/libcursesw.so               &&  \
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so               &&  \
ln -sfv libncurses.so      /usr/lib/libcurses.so                &&  \
rm -fv /usr/lib/libncurses++w.a                                 &&  \
mkdir -v       /usr/share/doc/ncurses-6.2                       &&  \
cp -v -R doc/* /usr/share/doc/ncurses-6.2                       &&  \
make distclean                                                  &&  \
./configure --prefix=/usr    \
            --with-shared    \
            --without-normal \
            --without-debug  \
            --without-cxx-binding \
            --with-abi-version=5                                &&  \
make sources libs                                               &&  \
cp -av lib/lib*.so.5* /usr/lib ) > /logs/ncurses-2 2>&1         &&  \
rm -rf sources/ncurses-*/

# Install sed

( cd sources && tar -xf sed-*.tar.xz && cd sed-*/       &&  \
./configure --prefix=/usr --bindir=/bin                 &&  \
make && make html                                       &&  \
chown -Rv tester .                                      &&  \
su tester -c "PATH=$PATH make check"                    &&  \
make install                                            &&  \
install -d -m755           /usr/share/doc/sed-4.8       &&  \
install -m644 doc/sed.html /usr/share/doc/sed-4.8 ) > /logs/sed 2>&1  &&  \
rm -rf sources/sed-*/

# Install psmisc
( cd sources && tar -xf psmisc-*.tar.xz && cd psmisc-*/       &&  \
./configure --prefix=/usr                                     &&  \
make && make install                                          &&  \
mv -v /usr/bin/fuser   /bin                                   &&  \
mv -v /usr/bin/killall /bin ) > /logs/psmisc 2>&1             &&  \
rm -rf sources/psmisc-*/

# Install gettext
( cd sources && tar -xf gettext-*.tar.xz && cd gettext-*/       &&  \
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.21                &&  \
make && make check && make install                              &&  \
chmod -v 0755 /usr/lib/preloadable_libintl.so ) > /logs/gettext-2 2>&1 &&  \
rm -rf sources/gettext-*/

# Install bison

( cd sources && tar -xf bison-*.tar.xz && cd bison-*/         &&  \
./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.5 &&  \
make && make check && make install ) > /logs/bison-2 2>&1     &&  \
rm -rf sources/bison-*/

# Install grep
( cd sources && tar -xf grep-*.tar.xz && cd grep-*/         &&  \
./configure --prefix=/usr --bindir=/bin                     &&  \
make && make check && make install ) > /logs/grep 2>&1      &&  \
rm -rf sources/grep-*/

# Install bash
( cd sources && tar -xf bash-*.tar.gz && cd bash-*/         &&  \
sed -i  '/^bashline.o:.*shmbchar.h/a bashline.o: ${DEFDIR}/builtext.h' Makefile.in  &&  \
./configure --prefix=/usr                    \
            --docdir=/usr/share/doc/bash-5.1 \
            --without-bash-malloc            \
            --with-installed-readline                       &&  \
make && chown -Rv tester .                                  &&  \
su tester << EOF
PATH=$PATH make tests < $(tty)
EOF
make install                                                &&  \
mv -vf /usr/bin/bash /bin ) > /logs/bash-2 2>&1               &&  \
rm -rf sources/bash-*/


# RUN THE NEW BASH
# exec /bin/bash --login +h


# Install libtool
( cd sources && tar -xf libtool-*.tar.xz && cd libtool-*/         &&  \
./configure --prefix=/usr                                         &&  \
make && make check || true && make install                        &&  \
rm -fv /usr/lib/libltdl.a ) > /logs/libtool 2>&1                  &&  \
rm -rf sources/libtool-*/

# Install GDBM

( cd sources && tar -xf gdbm-*.tar.gz && cd gdbm-*/         &&  \
./configure --prefix=/usr    \
            --disable-static \
            --enable-libgdbm-compat                         &&  \
make && make check || true && make install ) > /logs/gdbm 2>&1      &&  \
rm -rf sources/gdbm-*/

# Install gperf
( cd sources && tar -xf gperf-*.tar.gz && cd gperf-*/         &&  \
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1   &&  \
make && make -j1 check && make install ) > /logs/gperf 2>&1   &&  \
rm -rf sources/gperf-*/

# Install expat
( cd sources && tar -xf expat-*.tar.xz && cd expat-*/         &&  \
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.2.10              &&  \
make && make check && make install                            &&  \
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.10 ) > /logs/expat 2>&1  &&  \
rm -rf sources/expat-*/

# Install inetutils
( cd sources && tar -xf inetutils-*.tar.xz && cd inetutils-*/         &&  \
./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers                                       &&  \
make && make check && make install                                  &&  \
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin                &&  \
mv -v /usr/bin/ifconfig /sbin ) > /logs/inetutils 2>&1               &&  \
rm -rf sources/inetutils-*/

# Install perl
( cd sources && tar -xf perl-*.tar.xz && cd perl-*/         &&  \
export BUILD_ZLIB=False                                     &&  \
export BUILD_BZIP2=0                                        &&  \
echo $BUILD_BZIP2 && echo $BUILD_ZLIB   &&  \
sh Configure -des                                         \
             -Dprefix=/usr                                \
             -Dvendorprefix=/usr                          \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl      \
             -Darchlib=/usr/lib/perl5/5.32/core_perl      \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl      \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl     \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl  \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl \
             -Dman1dir=/usr/share/man/man1                \
             -Dman3dir=/usr/share/man/man3                \
             -Dpager="/usr/bin/less -isR"                 \
             -Duseshrplib                                 \
             -Dusethreads                                   &&  \
make && make test || true && make install                   &&  \
unset BUILD_ZLIB BUILD_BZIP2 ) >  /logs/perl-2 2>&1         &&  \
rm -rf sources/perl-*/

# Install xml

( cd sources && tar -xf XML-Parser-*.tar.gz && cd XML-*/         &&  \
perl Makefile.PL                                                        &&  \
make && make test || true && make install ) > /logs/xml-parser 2>&1     &&  \
rm -rf sources/XML-*/

# Install intltool

( cd sources && tar -xf intltool-*.tar.gz && cd intltool-*/         &&  \
sed -i 's:\\\${:\\\$\\{:' intltool-update.in                        &&  \
./configure --prefix=/usr                                           &&  \
make && make check && make install                                  &&  \
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO ) > /logs/intltool 2>&1 && \
rm -rf sources/intltool-*/

# Install autoconf
( cd sources && tar -xf autoconf-*.tar.xz && cd autoconf-*/         &&  \
./configure --prefix=/usr                                           &&  \
make && make check && make install ) > /logs/autoconf 2>&1           &&  \
rm -rf sources/autoconf-*/

# Install automake
( cd sources && tar -xf automake-*.tar.xz && cd automake-*/         &&  \
sed -i "s/''/etags/" t/tags-lisp-space.sh                           &&  \
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.3   &&  \
make && make check || true && make install ) > /logs/automake 2>&1          &&  \
rm -rf sources/automake-*/

# Install kmod
( cd sources && tar -xf kmod-*.tar.xz && cd kmod-*/         &&  \
./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zstd            \
            --with-zlib                                     &&  \
make && make install                                        &&  \
for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done                                                        &&  \
ln -sfv kmod /bin/lsmod  ) > /logs/kmod 2>&1                &&  \
rm -rf sources/kmod-*/

# Install libelf from elfutils
( cd sources && tar -xjf elfutils-*.tar.bz2 && cd elfutils-*/         &&  \
./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy \
            --libdir=/lib                                           &&  \
make && make check && make -C libelf install                        &&  \
install -vm644 config/libelf.pc /usr/lib/pkgconfig                  &&  \
rm /lib/libelf.a ) > /logs/elfutils 2>&1                            &&  \
rm -rf sources/elfutils-*/

# Install libffi

( cd sources && tar -xf libffi-*.tar.gz && cd libffi-*/             &&  \
./configure --prefix=/usr --disable-static --with-gcc-arch=native   &&  \
make && make check && make install ) > /logs/libffi 2>&1            &&  \
rm -rf sources/libffi-*/                                            &&  \

# Install opensll
( cd sources && tar -xf openssl-*.tar.gz && cd openssl-*/           &&  \
./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic                                               &&  \
make && make test || true                                           &&  \
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile            &&  \
make MANSUFFIX=ssl install                                          &&  \
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1j          &&  \
cp -vfr doc/* /usr/share/doc/openssl-1.1.1j ) > /logs/openssl 2>&1   &&  \
rm -rf sources/openssl-*/

# Install python

( cd sources && tar -xf Python-*.tar.xz && cd Python-*/           &&  \
./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes                                  &&  \
make && make test || true && make install                         &&  \
install -v -dm755 /usr/share/doc/python-3.9.2/html                &&  \
tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.9.2/html \
    -xvf ../python-3.9.2-docs-html.tar.bz2 ) > /logs/Python-2 2>&1  &&  \
rm -rf sources/Python-*/

# Install ninja

( cd sources && tar -xf ninja-*.tar.gz && cd ninja-*/           &&  \
export NINJAJOBS=4                                              &&  \
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc                                                  &&  \
python3 configure.py --bootstrap                                &&  \
./ninja ninja_test                                              &&  \
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots         &&  \
install -vm755 ninja /usr/bin/                                  &&  \
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja &&  \
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja ) > /logs/ninja 2>&1  &&  \
rm -rf sources/ninja-*/

# Install meson
( cd sources && tar -xf meson-*.tar.gz && cd meson-*/           &&  \
python3 setup.py build                                          &&  \
python3 setup.py install --root=dest                            &&  \
cp -rv dest/* / ) > /logs/meson 2>&1                            &&  \
rm -rf sources/meson-*/

# Install coreutils
( cd sources && tar -xf coreutils-*.tar.xz && cd coreutils-*/           &&  \
patch -Np1 -i ../coreutils-8.32-i18n-1.patch                            &&  \
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk                       &&  \
autoreconf -fiv                                                         &&  \
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime                     &&  \
make && make NON_ROOT_USERNAME=tester check-root                        &&  \
echo "dummy:x:102:tester" >> /etc/group                                 &&  \
chown -Rv tester .                                                      &&  \
su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"            &&  \
sed -i '/dummy/d' /etc/group                                            &&  \
make install                                                            &&  \
mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin          &&  \
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin                 &&  \
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin                        &&  \
mv -v /usr/bin/chroot /usr/sbin                                         &&  \
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8         &&  \
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8                        &&  \
mv -v /usr/bin/{head,nice,sleep,touch} /bin ) > /logs/coreutils-2 2>&1  &&  \
rm -rf sources/coreutils-*/


# Install check

( cd sources && tar -xf check-*.tar.gz && cd check-*/           &&  \
./configure --prefix=/usr --disable-static                      &&  \
make && make check                                              &&  \
make docdir=/usr/share/doc/check-0.15.2 install ) > /logs/check 2>&1  &&  \
rm -rf sources/check-*/

# Install diffutils

( cd sources && tar -xf diffutils-*.tar.xz && cd diffutils-*/   &&  \
./configure --prefix=/usr                                       &&  \
make && make check && make install ) > /logs/diffutils-2 2>&1   &&  \
rm -rf sources/diffutils-*/

# Install gawk
( cd sources && tar -xf gawk-*.tar.xz && cd gawk-*/   &&  \
sed -i 's/extras//' Makefile.in                       &&  \
./configure --prefix=/usr                             &&  \
make && make check && make install                    &&  \
mkdir -v /usr/share/doc/gawk-5.1.0                    &&  \
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0 ) > /logs/gawk-2 2>&1   &&  \
rm -rf sources/gawk-*/

# Install findutils

( cd sources && tar -xf findutils-*.tar.xz && cd findutils-*/   &&  \
./configure --prefix=/usr --localstatedir=/var/lib/locate       &&  \
make                                                            &&  \
chown -Rv tester .                                              &&  \
su tester -c "PATH=$PATH make check"                            &&  \
make install                                                    &&  \
mv -v /usr/bin/find /bin                                        &&  \
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb ) > /logs/findutils-2 2>&1 &&  \
rm -rf sources/findutils-*/

# Install groff
( cd sources && tar -xf groff-*.tar.gz && cd groff-*/   &&  \
PAGE=letter ./configure --prefix=/usr                   &&  \
make -j1 && make install ) > /logs/groff 2>&1           &&  \
rm -rf sources/groff-*/

# Install grub
( cd sources && tar -xf grub-*.tar.xz && cd grub-*/   &&  \
sed "s/gold-version/& -R .note.gnu.property/" \
    -i Makefile.in grub-core/Makefile.in
./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror                          &&  \
make && make install                                  &&  \
mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions ) > /logs/grub 2>&1 && \
rm -rf sources/groff-*/

# Install less
( cd sources && tar -xf less-*.tar.gz && cd less-*/   &&  \
./configure --prefix=/usr --sysconfdir=/etc           &&  \
make && make install ) > /logs/less 2>&1              &&  \
rm -rf sources/less-*/

# Install gzip
( cd sources && tar -xf gzip-*.tar.xz && cd gzip-*/   &&  \
./configure --prefix=/usr                             &&  \
make && make check && make install                    &&  \
mv -v /usr/bin/gzip /bin ) > /logs/gzip 2>&1          &&  \
rm -rf sources/gzip-*/

# Install iproutes2

( cd sources && tar -xf iproute2-*.tar.xz && cd iproute2-*/   &&  \
sed -i /ARPD/d Makefile                                         &&  \
rm -fv man/man8/arpd.8                                          &&  \
sed -i 's/.m_ipt.o//' tc/Makefile                               &&  \
make                                                            &&  \
make DOCDIR=/usr/share/doc/iproute2-5.10.0 install ) > /logs/iproute2 2>&1 &&  \
rm -rf sources/iproute2-*/

# Install kbd, will not install docs
( cd sources && tar -xf kbd-*.tar.xz && cd kbd-*/     &&  \
patch -Np1 -i ../kbd-2.4.0-backspace-1.patch          &&  \
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure       &&  \
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in  &&  \
./configure --prefix=/usr --disable-vlock             &&  \
make && make check && make install ) > /logs/kbd 2>&1 &&  \
rm -rf sources/kbd-*/

# Install libpipeline
( cd sources && tar -xf libpipeline-*.tar.gz && cd libpipeline-*/     &&  \
./configure --prefix=/usr                                             &&  \
make && make check && make install ) > /logs/libpipeline 2>&1         &&  \
rm -rf sources/libpipeline-*/

# Install make
( cd sources && tar -xf make-*.tar.gz && cd make-*/     &&  \
./configure --prefix=/usr                               &&  \
make && make check && make install ) > /logs/make 2>&1  &&  \
rm -rf sources/make-*/

# Install patch

( cd sources && tar -xf patch-*.tar.xz && cd patch-*/     &&  \
./configure --prefix=/usr                                 &&  \
make && make check && make install ) > /logs/patch 2>&1   &&  \
rm -rf sources/patch-*/

# Install man db
( cd sources && tar -xf man-db-*.tar.xz && cd man-*/     &&  \
./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.9.4 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=           \
            --with-systemdsystemunitdir=                    &&  \
make && make check && make install ) > /logs/mandb 2>&1     &&  \
rm -rf sources/man-*/

# Install tar
( cd sources && tar -xf tar-*.tar.xz && cd tar-*/     &&  \
FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin                             &&  \
make && make check || true && make install                    &&  \
make -C doc install-html docdir=/usr/share/doc/tar-1.34 ) > /logs/tar 2>&1     &&  \
rm -rf sources/tar-*/

# Install texinfo
( cd sources && tar -xf texinfo-*.tar.xz && cd texinfo-*/     &&  \
./configure --prefix=/usr                                     &&  \
make && make check && make install                            &&  \
make TEXMF=/usr/share/texmf install-tex ) > /logs/texinfo-2 2>&1     &&  \
rm -rf sources/texinfo-*/

# Install vim
( cd sources && tar -xf vim-*.tar.gz && cd vim-*/     &&  \
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h &&  \
./configure --prefix=/usr                                   &&  \
make                                                        &&  \
chown -Rv tester .                                          &&  \
su tester -c "LANG=en_US.UTF-8 make -j1 test"               &&  \
make install                                                  &&  \
ln -sv vim /usr/bin/vi                                        &&  \
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done                                                          &&  \
ln -sv ../vim/vim82/doc /usr/share/doc/vim-8.2.2433           &&  \
cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF
) > /logs/vim 2>&1     &&  \
rm -rf sources/vim-*/

# Install eudev
( cd sources && tar -xf eudev-*.tar.gz && cd eudev-*/     &&  \
./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static                              &&  \
make                                                      &&  \
mkdir -pv /lib/udev/rules.d                               &&  \
mkdir -pv /etc/udev/rules.d                               &&  \
make check || true && make install                                &&  \
tar -xvf ../udev-lfs-20171102.tar.xz                      &&  \
make -f udev-lfs-20171102/Makefile.lfs install            &&  \
udevadm hwdb --update ) > /logs/eudev 2>&1                &&  \
rm -rf sources/eudev-*/

# Install procps-ng

( cd sources && tar -xf procps-*.tar.xz && cd procps-*/     &&  \
./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.17 \
            --disable-static                         \
            --disable-kill                                  &&  \
make && make check || true && make install                          &&  \
mv -v /usr/lib/libprocps.so.* /lib                          &&  \
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so ) > /logs/procpsng 2>&1 &&  \
rm -rf sources/procps-*/

# Install util linux

( cd sources && tar -xf util-linux-*.tar.xz && cd util-linux-*/     &&  \
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.36.2 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir \
            runstatedir=/run                                        &&  \
make && make install ) > /logs/util-linux 2>&1                      &&  \
rm -rf sources/util-linux-*/

# Install E2fsprogs
( cd sources && tar -xf e2fsprogs-*.tar.gz && cd e2fsprogs-*/     &&  \
mkdir -v build && cd build &&  \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck                                       &&  \
make && make check || true && make install                                &&  \
rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a             &&  \
gunzip -v /usr/share/info/libext2fs.info.gz                       &&  \
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info  &&  \
makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo                 &&  \
install -v -m644 doc/com_err.info /usr/share/info                           &&  \
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info ) > /logs/e2fsprogs 2>&1 &&  \
rm -rf sources/e2fsprogs-*/


# Install sysklogd

( cd sources && tar -xf sysklogd-*.tar.gz && cd sysklogd-*/     &&  \
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c       &&  \
sed -i 's/union wait/int/' syslogd.c                            &&  \
make && make BINDIR=/sbin install                               &&  \
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF
) > /logs/sysklogd 2>&1 &&  \
rm -rf sources/sysklogd-*/

# Install sysvinit

( cd sources && tar -xf sysvinit-*.tar.xz && cd sysvinit-*/     &&  \
patch -Np1 -i ../sysvinit-2.98-consolidated-1.patch             &&  \
make && make install ) > /logs/sysvinit 2>&1                    &&  \
rm -rf sources/sysvinit-*/




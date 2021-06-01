#!/bin/bash

# Compiling a cross tool chain

# Compile binutils
( tar -xf binutils-*.tar.xz && cd binutils-*/ && mkdir -v build && cd build &&\
time {  ../configure                    \
        --prefix=$LFS/tools             \
        --with-sysroot=$LFS             \
        --target=$LFS_TGT               \
        --disable-nls--disable-werror   \
        && make -j1 && make install -j1; } ) > $LFS/logs/binutils-1 2>&1 && \
rm -rf binutils-*/

# Compile gcc
( tar -xf gcc-*.tar.xz && cd gcc-*/ &&                  \
tar -xf ../mpfr-*.tar.xz && mv -v mpfr-*/ mpfr &&       \
tar -xf ../gmp-*.tar.xz && mv -v gmp-*/ gmp &&          \
tar -xf ../mpc-*.tar.gz && mv -v mpc-*/ mpc &&          \
case $(uname -m) in  x86_64)    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;esac && \
mkdir -v build && cd build && \
time {  ../configure                 \
        --target=$LFS_TGT            \
        --prefix=$LFS/tools          \
        --with-glibc-version=2.11    \
        --with-sysroot=$LFS          \
        --with-newlib                \
        --without-headers            \
        --enable-initfini-array      \
        --disable-nls                \
        --disable-shared             \
        --disable-multilib           \
        --disable-decimal-float      \
        --disable-threads            \
        --disable-libatomic          \
        --disable-libgomp            \
        --disable-libquadmath        \
        --disable-libssp             \
        --disable-libvtv             \
        --disable-libstdcxx          \
        --enable-languages=c,c++     \
        && make && make install; } &&\
cd .. && cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h) > $LFS/logs/gcc-1 2>&1 &&\
rm -rf gcc-*/

# Install linux API headers

( tar -xf linux-*.tar.xz && cd linux-*/ && make mrproper && make headers &&                     \
find usr/include -name '.*' -delete &&                                                          \
rm usr/include/Makefile && cp -rv usr/include $LFS/usr) > $LFS/logs/linux-headers 2>&1 &&       \
rm -rf linux-*/

# Compile Glibc
( tar -xf glibc-*.tar.xz && cd glibc-*/ && \
case $(uname -m) in
    i?86)       ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64)     ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
esac &&\
patch -Np1 -i ../glibc-*-fhs-1.patch && mkdir -v build && cd build && \
time {  ../configure                       \
        --prefix=/usr                      \
        --host=$LFS_TGT                    \
        --build=$(../scripts/config.guess) \
        --enable-kernel=3.2                \
        --with-headers=$LFS/usr/include    \
        libc_cv_slibdir=/lib               \
        && make -j1 && make -j1 DESTDIR=$LFS install; } ) > $LFS/logs/glibc 2>&1 && \
rm -rf glibc-*/

# Perform sanity check

echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep '/ld-linux' > $LFS/logs/sanity-check 2>&1
rm -v dummy.c a.out

$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders

# Compile Libstdc++

( tar -xf gcc-*.tar.xz && cd gcc-*/ &&\
mkdir -v build && cd build && \
time {  ../libstdc++-v3/configure       \
        --host=$LFS_TGT                 \
        --build=$(../config.guess)      \
        --prefix=/usr                   \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0\
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/libstdc-1 2>&1 && \
rm -rf gcc-*/


# Compile M4

( tar -xf m4-*.tar.xz && cd m4-*/ &&                            \
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c &&              \
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h &&       \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) && \
        make && make DESTDIR=$LFS install; } ) > $LFS/logs/m4 2>&1 && \
rm -rf m4-*/

# Compile ncurses

( tar -xf ncurses-*.tar.gz && cd ncurses-*/ &&                                  \
sed -i s/mawk// configure && mkdir -v build && pushd build &&                   \
time { ../configure && make -C include && make -C progs tic; } && popd &&       \
time {  ./configure                     \
        --prefix=/usr                   \
        --host=$LFS_TGT                 \
        --build=$(./config.guess)       \
        --mandir=/usr/share/man         \
        --with-manpage-format=normal    \
        --with-shared                   \
        --without-debug                 \
        --without-ada                   \
        --without-normal                \
        --enable-widec &&               \
        make && make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install &&    \
        echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so; } &&             \
mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib &&                                \
ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so ) > $LFS/logs/ncurses 2>&1 && \
rm -rf ncurses-*/

# Compile bash

( tar -xf bash-*.tar.gz && cd bash-*/ &&\
time {  ./configure                     \
        --prefix=/usr                   \
        --build=$(support/config.guess) \
        --host=$LFS_TGT                 \
        --without-bash-malloc           \
        && make && make DESTDIR=$LFS install; } && \
        mv $LFS/usr/bin/bash $LFS/bin/bash && \
        ln -sv bash $LFS/bin/sh ) > $LFS/logs/bash 2>&1 && \
rm -rf bash-*/

# compile Coreutils

( tar -xf coreutils-*.tar.xz && cd coreutils-*/ && \
time {  ./configure                             \
        --prefix=/usr                           \
        --host=$LFS_TGT                         \
        --build=$(build-aux/config.guess)       \
        --enable-install-program=hostname       \
        --enable-no-install-program=kill,uptime \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/coreutils 2>&1 && \
mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin          && \
mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin          && \
mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin          && \
mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin          && \
mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin     && \
mkdir -pv $LFS/usr/share/man/man8                                               && \
mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8 && \
sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8 && \
rm -rf coreutils-*/


# compile diffutils

( tar -xf diffutils-*.tar.xz && cd diffutils-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/diffutils 2>&1 && \
rm -rf diffutils-*/


# compile file

( tar -xf file-*.tar.gz && cd file-*/ && \
mkdir -v build && pushd build && \
time {  ../configure            \
        --disable-bzlib         \
        --disable-libseccomp    \
        --disable-xzlib         \
        --disable-zlib          \
        && make && popd;        }    && \
time {  ./configure                     \
        --prefix=/usr                   \
        --host=$LFS_TGT                 \
        --build=$(./config.guess)       \
        && make FILE_COMPILE=$(pwd)/build/src/file \
        && make DESTDIR=$LFS install;   }) > $LFS/logs/file 2>&1 && \
rm -rf file-*/

# compile findutils

( tar -xf findutils-*.tar.xz && cd findutils-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) && \
        make && make DESTDIR=$LFS install; } && \
mv -v $LFS/usr/bin/find $LFS/bin && \
sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb ) > $LFS/logs/findutils 2>&1 && \
rm -rf findutils-*/


# compile gawk

( tar -xf gawk-*.tar.xz && cd gawk-*/ && \
sed -i 's/extras//' Makefile.in && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        --build=$(./config.guess) \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/gawk 2>&1 && \
rm -rf gawk-*/

# compile grep

( tar -xf grep-*.tar.xz && cd grep-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        --bindir=/bin   \
        && make && make DESTDIR=$LFS install; }) > $LFS/logs/grep 2>&1 && \
rm -rf grep-*/

# compile gzip

( tar -xf gzip-*.tar.xz && cd gzip-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        && make && make DESTDIR=$LFS install; } && \
mv -v $LFS/usr/bin/gzip $LFS/bin ) > $LFS/logs/gzip 2>&1 && \
rm -rf gzip-*/

# compile make

( tar -xf make-*.tar.gz && cd make-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --without-guile \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/make 2>&1 && \
rm -rf make-*/

# compile patch

( tar -xf patch-*.tar.xz && cd patch-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        --build=$(build-aux/config.guess) \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/patch 2>&1 && \
rm -rf patch-*/

# compile sed

( tar -xf sed-*.tar.xz && cd sed-*/ && \
time {  ./configure     \
        --prefix=/usr   \
        --host=$LFS_TGT \
        --bindir=/bin   \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/sed 2>&1 && \
rm -rf sed-*/

# compile tar

( tar -xf tar-*.tar.xz && cd tar-*/ && \
time {  ./configure                             \
        --prefix=/usr                           \
        --host=$LFS_TGT                         \
        --build=$(build-aux/config.guess)       \
        --bindir=/bin                           \
        && make && make DESTDIR=$LFS install; } ) > $LFS/logs/tar 2>&1 && \
rm -rf tar-*/

# compile xz

( tar -xf xz-*.tar.xz && cd xz-*/ && \
time {  ./configure                             \
        --prefix=/usr                           \
        --host=$LFS_TGT                         \
        --build=$(build-aux/config.guess)       \
        --disable-static                        \
        --docdir=/usr/share/doc/xz-5.2.5        \
        && make && make DESTDIR=$LFS install; } && \
mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin && \
mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib && \
ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so ) > $LFS/logs/xz 2>&1 && \
rm -rf xz-*/

# compile binutils pass 2

( tar -xf binutils-*.tar.xz && cd binutils-*/ && \
mkdir -v build && cd build && \
time {  ../configure                    \
        --prefix=/usr                   \
        --build=$(../config.guess)      \
        --host=$LFS_TGT                 \
        --disable-nls                   \
        --enable-shared                 \
        --disable-werror                \
        --enable-64-bit-bfd             \
        && make -j1 && make -j1 DESTDIR=$LFS install \
        && install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib; } ) > $LFS/logs/binutils-2 2>&1 && \
rm -rf binutils-*/

# compile gcc pass 2

( tar -xf gcc-*.tar.xz && cd gcc-*/ &&                  \
tar -xf ../mpfr-*.tar.xz && mv -v mpfr-*/ mpfr &&       \
tar -xf ../gmp-*.tar.xz && mv -v gmp-*/ gmp &&             \
tar -xf ../mpc-*.tar.gz && mv -v mpc-*/ mpc &&             \
case $(uname -m) in  x86_64)    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;esac && \
mkdir -v build && cd build &&   \
mkdir -pv $LFS_TGT/libgcc &&    \
ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h && \
time {  ../configure                                    \
        --build=$(../config.guess)                      \
        --host=$LFS_TGT                                 \
        --prefix=/usr                                   \
        CC_FOR_TARGET=$LFS_TGT-gcc                      \
        --with-build-sysroot=$LFS                       \
        --enable-initfini-array                         \
        --disable-nls                                   \
        --disable-multilib                              \
        --disable-decimal-float                         \
        --disable-libatomic                             \
        --disable-libgomp                               \
        --disable-libquadmath                           \
        --disable-libssp                                \
        --disable-libvtv                                \
        --disable-libstdcxx                             \
        --enable-languages=c,c++                        \
        && make && make DESTDIR=$LFS install && ln -sv gcc $LFS/usr/bin/cc; } ) > $LFS/logs/gcc-2 2>&1 && \
rm -rf gcc-*/


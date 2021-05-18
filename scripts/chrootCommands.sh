#!/bin/bash

mkdir -pv /{boot,home,mnt,opt,srv}
mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{floppy,cdrom}
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /var/{cache,local,log,mail,opt,spool}
mkdir -pv /var/lib/{color,misc,locate}

ln -sfv /run /var/run
ln -sfv /run/lock /var/lock
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp

ln -sv /proc/self/mounts /etc/mtab
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF

echo "tester:x:$(ls -n $(tty) | cut -d" " -f3):101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

# for manual testing & just for reference (remove i have no name prompt)
# exec /bin/bash --login +h

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp


# install libstdc part 2

( cd sources && tar -xf gcc-*.tar.xz && cd gcc-*/ &&    \
ln -s gthr-posix.h libgcc/gthr-default.h &&             \
mkdir -v build && cd build &&                           \
time {  ../libstdc++-v3/configure             \
        CXXFLAGS="-g -O2 -D_GNU_SOURCE"       \
        --prefix=/usr                         \
        --disable-multilib                    \
        --disable-nls                         \
        --host=$(uname -m)-lfs-linux-gnu      \
        --disable-libstdcxx-pch               \
        && make && make install;              } ) > /logs/libstdc-2 2>&1 &&    \
rm -rf sources/gcc-*/

# install gettext

( cd sources && tar -xf gettext-*.tar.xz && cd gettext-*/ &&    \
time {  ./configure --disable-shared && make; } &&              \
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin ) > /logs/gettext 2>&1 &&\
rm -rf sources/gettext-*/

# install bison

( cd sources && tar -xf bison-*.tar.xz && cd bison-*/ &&    \
time {  ./configure     \
        --prefix=/usr   \
        --docdir=/usr/share/doc/bison-3.7.5 \
        && make && make install; } ) > /logs/bison 2>&1 && \
rm -rf sources/bison-*/

# install perl

( cd sources && tar -xf perl-*.tar.xz && cd perl-*/ &&  \
time {  sh Configure -des                               \
        -Dprefix=/usr                                   \
        -Dvendorprefix=/usr                             \
        -Dprivlib=/usr/lib/perl5/5.32/core_perl         \
        -Darchlib=/usr/lib/perl5/5.32/core_perl         \
        -Dsitelib=/usr/lib/perl5/5.32/site_perl         \
        -Dsitearch=/usr/lib/perl5/5.32/site_perl        \
        -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl     \
        -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl    \
        && make && make install; } ) > /logs/perl 2>&1 &&                 \
rm -rf sources/perl-*/


# install python

( cd sources && tar -xf Python-*.tar.xz && cd Python-*/ &&  \
time {  ./configure     \
        --prefix=/usr   \
        --enable-shared \
        --without-ensurepip \
        && make && make install; } ) > /logs/python 2>&1 && \
rm -rf sources/Python-*/

# intall texinfo

( cd sources && tar -xf texinfo-*.tar.xz && cd texinfo-*/ &&    \
time { ./configure --prefix=/usr && make && make install; } ) > /logs/texinfo 2>&1 && \
rm -rf sources/texinfo-*/

# install util-linux

( cd sources && tar -xf util-linux-*.tar.xz && cd util-linux-*/ &&    \
mkdir -pv /var/lib/hwclock && \
time {  ./configure     \
        ADJTIME_PATH=/var/lib/hwclock/adjtime           \
        --docdir=/usr/share/doc/util-linux-2.36.2       \
        --disable-chfn-chsh                             \
        --disable-login                                 \
        --disable-nologin                               \
        --disable-su                                    \
        --disable-setpriv                               \
        --disable-runuser                               \
        --disable-pylibmount                            \
        --disable-static                                \
        --without-python                                \
        runstatedir=/run                                \
        && make && make install; } ) > /logs/util-linux 2>&1 &&                 \
rm -rf sources/util-linux-*/



# Cleaning up & saving


# Remove libtool.la files
find /usr/{lib,libexec} -name \*.la -delete
# Remove docs
rm -rf /usr/share/{info,man,doc}/*




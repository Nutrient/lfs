FROM debian

# Install required libs
RUN apt-get update && \
    apt-get install  -y \
    sudo \
    xz-utils \
    texinfo \
    make \
    m4 \
    python3 \
    g++ \
    patch \
    gawk \
    bison

# Create a symbolic link to bash
RUN rm /bin/sh && ln -s bash /bin/sh

# LFS mount point
ENV LFS=/mnt/lfs
# loop device
ENV LOOP=/dev/loop0
# In KBs (10GB)
#ENV IMAGE_SIZE=10000000
# 1GB for testing
ENV IMAGE_SIZE=1000000

COPY . /workdir
WORKDIR /workdir

ENTRYPOINT ["bash", "./scripts/init.sh"]
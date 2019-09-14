# This is only useful if you wish to compile your own GCC from git for GCC9
# Will no longer be used since GCC 9.2 is now available in alpine:edge.
# May be useful you really want some super-bleeding edge GCC (like, from current git)

FROM alpine as gcc-builder

RUN apk add --quiet --no-cache \
            build-base \
            flex \
            dejagnu \
            isl-dev \
            git \
            make \
            mpc1-dev \
            mpfr-dev \
            texinfo \
            zlib-dev

RUN git clone git://gcc.gnu.org/git/gcc.git

WORKDIR /gcc

RUN ./configure \
        --prefix=/usr/local \
        --build=$(uname -m)-alpine-linux-musl \
        --host=$(uname -m)-alpine-linux-musl \
        --target=$(uname -m)-alpine-linux-musl \
        --enable-checking=release \
        --disable-fixed-point \
        --disable-libmpx \
        --disable-libmudflap \
        --disable-libsanitizer \
        --disable-libssp \
        --disable-libstdcxx-pch \
        --disable-multilib \
        --disable-nls \
        --disable-symvers \
        --disable-werror \
        --enable-__cxa_atexit \
        --enable-default-pie \
        --enable-languages=c,c++ \
        --enable-shared \
        --enable-threads \
        --enable-tls \
        --with-linker-hash-style=gnu \
        --with-system-zlib
RUN make --silent -j $(nproc)
RUN make --silent -j $(nproc) install-strip

RUN gcc -v
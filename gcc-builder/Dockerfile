# This is only useful if you wish to compile your own GCC.
# No longer required since GCC was added to Alpine Edge Repo

FROM alpine as gcc-builder

ENV GCC_VERSION 8.2.0

RUN apk add --quiet --no-cache \
            build-base \
            dejagnu \
            isl-dev \
            make \
            mpc1-dev \
            mpfr-dev \
            texinfo \
            zlib-dev
RUN wget -q https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz && \
    tar -xzf gcc-${GCC_VERSION}.tar.gz && \
    rm -f gcc-${GCC_VERSION}.tar.gz

WORKDIR /gcc-${GCC_VERSION}

RUN ./configure \
        --prefix=/usr/local \
        --build=$(uname -m)-alpine-linux-musl \
        --host=$(uname -m)-alpine-linux-musl \
        --target=$(uname -m)-alpine-linux-musl \
        --with-pkgversion="Alpine ${GCC_VERSION}" \
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
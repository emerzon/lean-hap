# ----------------------------------------------------------------------------------------------------------------------
# - HAProxy Image Build
#
# Again, we aim to handle all dependencies here without resorting to alpine libs.
# Might be a bit annoying, but recompiling them ensure we will have most optimal performance on each of them.
# Also we want some unusual compilation settings for HAProxy, like using libSZL instead of Zlib.
# See more on http://www.libslz.org/
#
# PERFORMAAAANCE!!!

FROM builder as haproxy-builder

# TODO: Would be nice to have something here to resolve latest versions automatically.
ENV HAPROXY_VERSION 1.9.2
ENV LIBRESSL_VERSION 2.9.0
ENV LUA_VERSION 5.3.5
ENV NCURSES_VERSION 6.1
ENV PCRE_VERSION 8.42
ENV PCRE2_VERSION 10.32
ENV READLINE_VERSION 8.0
ENV SLZ_VERSION master
ENV ZLIB_VERSION 1.2.11
# Just comment below if you want to skip some module.
ENV HAPROXY_URL http://www.haproxy.org/download/${HAPROXY_VERSION::3}/src/haproxy-${HAPROXY_VERSION}.tar.gz
ENV LIBRESSL_URL http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
ENV LUA_URL http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz
ENV NCURSES_URL https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
ENV PCRE_URL https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz
ENV PCRE2_URL https://ftp.pcre.org/pub/pcre/pcre2-${PCRE2_VERSION}.tar.gz
ENV READLINE_URL https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz
ENV SLZ_URL http://git.1wt.eu/web/libslz.git/
#ENV ZLIB_URL http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz

RUN set -xe; \
	mkdir -p /usr/src; \
	cd /usr/src; \
    for i in ${HAPROXY_URL} ${LIBRESSL_URL} ${LUA_URL} ${NCURSES_URL} ${PCRE_URL} ${PCRE2_URL} ${READLINE_VERSION}; \
    do; curl ${i} | tar xvz; \
    done; \
    git clone http://git.1wt.eu/git/libslz.git/;

RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/ncurses*; \
    ./configure --enable-shared=no; \
    make -j $(nproc) && make install; \
    cd /usr/src/zlib*; \
    ./configure --static; \
    make -j $(nproc) && make install; \
    cd /usr/src/readline*; \
    ./configure --enable-static=true; \
    make -j $(nproc) && make install; \
    cd /usr/src/lua*; \
    make -j $(nproc) && make install; \
    cd /usr/src/libressl*; \
    ./configure --enable-shared=no; \
    make -j $(nproc) && make install; \
    cd /usr/src/pcre-*; \
    ./configure --enable-shared=no --enable-utf8 --enable-jit; \
    make && make install; \
    cd /usr/src/libslz*; \
    make && make install; \
    cd /usr/src/haproxy*; \
    make TARGET=linux2628 USE_PCRE_JIT=1 USE_LUA=1 USE_ZLIB=1 USE_STATIC_PCRE=1 USE_OPENSSL=1 ADDLIB="-ldl -lrt -lz"; \
    make install
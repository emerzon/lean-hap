# ----------------------------------------------------------------------------------------------------------------------
# - HAProxy Image Build
#
# Again, we aim to handle all dependencies here without resorting to alpine libs.
# Might be a bit annoying, but recompiling them ensure we will have most optimal performance on each of them.
# Also we want some unusual compilation settings for HAProxy, like using libSZL instead of Zlib.
# See more on http://www.libslz.org/
#
# PERFORMAAAANCE!!!

FROM lean-hap_builder as haproxy-builder

# TODO: Would be nice to have something here to resolve latest versions automatically.
ENV HAPROXY_VERSION 1.9.4

# -- Pick only one below ----------------------------------------------------------------
#ENV LIBRESSL_VERSION 2.4.5
ENV OPENSSL_VERSION 1.1.1a
# ---------------------------------------------------------------------------------------

# -- Lua and it's dependencies ----------------------------------------------------------
ENV LUA_VERSION 5.3.5
ENV NCURSES_VERSION 6.1
ENV READLINE_VERSION 6.3
# ---------------------------------------------------------------------------------------

# -- While you can compile both PCRE and PCRE2 simultaneously... Do you really need both?
ENV PCRE_VERSION 8.42
ENV PCRE2_VERSION 10.32
# ---------------------------------------------------------------------------------------

# -- Pick only one below ----------------------------------------------------------------
ENV SLZ_VERSION master
#ENV ZLIB_VERSION 1.2.11
# ---------------------------------------------------------------------------------------

ENV HAPROXY_URL http://www.haproxy.org/download/1.9/src/haproxy-${HAPROXY_VERSION}.tar.gz
#ENV LIBRESSL_URL http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz
ENV OPENSSL_URL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
#ENV LUA_URL http://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz
#ENV NCURSES_URL https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz
#ENV PCRE_URL https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz
ENV PCRE2_URL https://ftp.pcre.org/pub/pcre/pcre2-${PCRE2_VERSION}.tar.gz
#ENV READLINE_URL https://ftp.gnu.org/gnu/readline/readline-${READLINE_VERSION}.tar.gz
ENV SLZ_URL http://git.1wt.eu/web/libslz.git/
#ENV ZLIB_URL http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz


# This will download all the files needed
RUN set -xe; \
    apk add --no-cache linux-headers; \
	mkdir -p /usr/src; \
	cd /usr/src; \
    for i in ${HAPROXY_URL} ${OPENSSL_URL} ${LIBRESSL_URL} ${LUA_URL} ${NCURSES_URL} ${READLINE_URL} ${PCRE_URL} ${PCRE2_URL}; \
    do curl ${i} | tar xvz; \
    done; \
    git clone http://git.1wt.eu/git/libslz.git/

# ---- LUA Building below is broken :(
#
# Build Zlib
#RUN set -xe; \
#	export CFLAGS="${CUSTOM_CFLAGS}"; \
#	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
#   cd /usr/src/zlib*; \
#   ./configure --prefix=/usr/local/; \
#   make -j $(nproc) && make install; \


# Build Readline
#RUN set -xe; \
#	export CFLAGS="${CUSTOM_CFLAGS}"; \
#	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
#    cd /usr/src/readline*; \
#    ./configure --prefix=/usr/local/; \
#    make -j $(nproc) && make install; \

# Build Ncurses
#RUN set -xe; \
#	export CFLAGS="${CUSTOM_CFLAGS}"; \
#	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
#    cd /usr/src/ncurses*; \
#    ./configure --prefix=/usr/local/; \
#    make -j $(nproc) && make install; \

# Build Lua
#RUN set -xe; \
#    cd /usr/src/lua*; \
#    make -j $(nproc) MYCFLAGS="${CUSTOM_CFLAGS} -I/usr/static/readline/include" \
#    MYLDFLAGS="-L/usr/static/readline/lib -L/usr/static/ncurses/lib -lreadline -lncurses" linux && make install

# Build LibreSSL - Potencially broken
#RUN set -xe; \
#	export CFLAGS="${CUSTOM_CFLAGS}"; \
#	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
#    cd /usr/src/libressl*; \
#    ./configure; \
#    make -j $(nproc) && make install

# Build OpenSSL
RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/openssl*; \
    ./config; \
    make -j $(nproc) && make install_sw

# Build PCRE
#RUN set -xe; \
#	export CFLAGS="${CUSTOM_CFLAGS}"; \
#	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
#    cd /usr/src/pcre-*; \
#    ./configure --enable-utf8 --enable-jit; \
#    make && make install

# Build PCRE2
RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/pcre2-*; \
    ./configure --enable-utf8 --enable-jit; \
    make && make install

# Build libslz
RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/libslz*; \
    make && make install

# Build HAProxy
RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/haproxy*; \
    make TARGET=linux2628 CFLAGS="${CFLAGS}" USE_PCRE2_JIT=1 USE_SLZ=1 USE_OPENSSL=1 USE_THREAD=1 USE_PTHREAD_PSHARED=1 \
    USE_REGPARM=1 USE_TFO=1 USE_NS=1; \
    make install; \
    find /usr/local/sbin /usr/local/lib -type f -perm +0111 -exec strip --strip-all '{}' + || true

FROM alpine

ADD ./entrypoint.sh /usr/bin/entrypoint

COPY --from=haproxy-builder /usr/local/lib /lib
COPY --from=haproxy-builder /usr/local/sbin /sbin

ENTRYPOINT [ "entrypoint" ]
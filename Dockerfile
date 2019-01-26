# - GCC8 Build Start-

FROM alpine as gccbuilder

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

# - GCC8 Build End -

#-----------------------------------------------------------------------------------------------------------------------

# - PHP7 Build Start -

FROM alpine as php-builder

# Customizable values:
ENV PHP_VERSION 7.3.1
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_CFLAGS "-fstack-protector-strong -fpic -fpie -O3 -march=native"
ENV PHP_URL "https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror"

ENV BUILD_PACKAGES="\
autoconf automake binutils ca-certificates cmake coreutils curl dpkg file git gmp gnupg isl libressl libtool make mpc1 \
mpfr3 pkgconf re2c tar wget xz"

ENV DEP_PACKAGES="\
argon2-dev libpng-dev freetype-dev libwebp-dev libjpeg-turbo-dev libxpm-dev libexif-dev \
curl-dev dpkg-dev imagemagick-dev gd-dev libzip-dev libc-dev musl-dev libedit-dev libressl-dev libsodium-dev \
libxml2-dev tidyhtml-dev sqlite-dev zlib-dev xmlrpc-c-dev libxslt-dev gettext-dev imap-dev openldap-dev icu-dev \
bzip2-dev libmcrypt-dev"

ENV PECL_EMBEDDED_PACKAGES="igbinary imagick mcrypt"
ENV PECL_MODULAR_PACKAGES="redis xdebug-2.7.0beta1"

RUN xargs apk add --no-cache ${BUILD_PACKAGES} ${DEP_PACKAGES}

COPY --from=gccbuilder /usr/local/ /usr/

RUN ln -s /usr/bin/gcc /usr/bin/cc

RUN set -xe; \
	mkdir -p /usr/src; \
	cd /usr/src; \
	wget -O php.tar.xz "${PHP_URL}";

RUN set -xe \
	&& export CFLAGS="${PHP_CFLAGS}" \
		CPPFLAGS="${PHP_CFLAGS}" \
		LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
	&& cd /usr/src \
	&& tar -xvJf php.tar.xz \
	&& ln -s php-"${PHP_VERSION}" php \
	&& cd /usr/src/php/ext \
	&& for i in ${PECL_EMBEDDED_PACKAGES}; do curl https://pecl.php.net/get/${i} | tar xvz; done \
	&& for i in *[0-9]\.[0-9]*; do mv $i $(echo $i | cut -f 1 -d \-); done \
    && cd /usr/src/php \
    && rm -f configure \
    && ./buildconf --force \
    && ./configure --help \
	&& ./configure \
		--with-config-file-path="${PHP_INI_DIR}" \
		--with-config-file-scan-dir="${PHP_INI_DIR}/conf.d" \
		--enable-option-checking=fatal \
		--enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --disable-cgi \
		--enable-embed=static \
		--enable-bcmath \
        --enable-calendar \
		--enable-embedded-mysqli \
		--enable-exif \
		--enable-ftp \
		--enable-igbinary \
		--enable-intl \
		--enable-mbstring \
		--enable-mysqlnd \
		--enable-pcntl \
		--enable-shmop \
		--enable-soap \
        --enable-sockets \
	    --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
		--enable-wddx \
		--enable-zip \
		--with-bz2 \
		--with-curl \
        --with-freetype-dir \
        --with-gd \
		--with-gettext \
		--with-imagick \
		--with-imap-ssl \
        --with-jpeg-dir \
		--with-ldap \
		--with-libedit \
		--with-libzip \
		--with-mhash \
		--with-openssl \
		--with-password-argon2 \
		--with-pdo-mysql \
        --with-png-dir \
		--with-sodium=shared \
        --with-tidy \
        --with-webp-dir \
		--with-xmlrpc \
        --with-xpm-dir \
		--with-xsl \
		--with-zlib \
        --with-zlib-dir \
	&& make -j "$(nproc)" \
	&& make install \
	&& { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; }

RUN pecl install ${PECL_MODULAR_PACKAGES}


# - PHP7 Build End -
# ----------------------------------------------------------------------------------------------------------------------
# - Runtime container Build Start -

FROM alpine

COPY --from=php-builder /usr/local/ /usr/

RUN runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/ \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add $runDeps

RUN set -x \
	&& addgroup -g 48 -S www-data \
	&& adduser -u 990 -D -S -G www-data www-data

CMD ["php-fpm"]

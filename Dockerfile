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

# - PHP7 Build Start -

FROM alpine as phpbuilder

RUN apk add --nocache autoconf \
            automake \
            binutils \
			ca-certificates \
            cmake \
            coreutils \
            curl \
            dpkg \
            file \
            git \
            gmp \
            gnupg \
            isl \
            libressl \
            libtool \
            make \
            mpc1 \
            mpfr3 \
            pkgconf \
            re2c \
            tar \
            wget \
            xz \
            argon2-dev libpng-dev freetype-dev libwebp-dev libjpeg-turbo-dev libxpm-dev libexif-dev \
            curl-dev dpkg-dev imagemagick-dev gd-dev libzip-dev libc-dev musl-dev libedit-dev libressl-dev \
            libsodium-dev libxml2-dev tidyhtml-dev sqlite-dev zlib-dev xmlrpc-c-dev libxslt-dev gettext-dev imap-dev openldap-dev icu-dev bzip2-dev libmcrypt-dev

COPY --from=gccbuilder /usr/local/ /usr/

RUN ln -s /usr/bin/gcc /usr/bin/cc

ENV PHP_INI_DIR /etc/php
ENV PHP_CFLAGS "-fstack-protector-strong -fpic -fpie -O3"
ENV PHP_VERSION 7.3.1
ENV PHP_URL "https://secure.php.net/get/php-$PHP_VERSION.tar.xz/from/this/mirror"

RUN set -xe; \
	mkdir -p /usr/src; \
	cd /usr/src; \
	wget -O php.tar.xz "$PHP_URL";

RUN set -xe \
	&& export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CFLAGS" \
		LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
	&& cd /usr/src \
	&& tar -xvJf php.tar.xz \
	&& ln -s php-7.3.1 php \
	&& cd /usr/src/php \
	&& ./configure \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		--enable-option-checking=fatal \
		--with-mhash \
		--enable-ftp \
		--enable-mbstring \
		--enable-mysqlnd \
	    --enable-sysvmsg \
        --enable-sysvsem \
        --enable-sysvshm \
        --enable-sockets \
        --enable-calendar \
        --with-tidy \
        --with-gd \
        --with-webp-dir \
        --with-jpeg-dir \
        --with-png-dir \
        --with-zlib-dir \
        --with-xpm-dir \
        --with-freetype-dir \
		--with-password-argon2 \
		--with-sodium=shared \
		--with-curl \
		--with-mhash \
		--with-xmlrpc \
		--with-libedit \
		--with-openssl \
		--enable-shmop \
		--enable-intl \
		--with-zlib \
		--enable-zip \
		--with-xsl \
		--with-libzip \
		--with-pdo-mysql \
		--with-imap-ssl \
		--enable-soap \
		--enable-pcntl \
		--enable-embedded-mysqli \
		--enable-exif \
		--with-gettext \
		--enable-wddx \
		--enable-bcmath \
		--with-bz2 \
		--with-ldap \
		--enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --disable-cgi \
	&& make -j "$(nproc)" \
	&& make install \
	&& pecl install igbinary imagick redis xdebug-2.7.0beta1 mcrypt-1.0.2 \
	&& { find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; }

#RUN pecl install ereg mysql mysqli pdo_mysql ssh2

# - PHP7 Build Start -

# - Runtime container Build Start -

FROM alpine

COPY --from=phpbuilder /usr/local/ /usr/

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

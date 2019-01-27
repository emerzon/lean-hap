FROM builder as php-builder

# Customizable values:
ENV PHP_VERSION 7.3.1
ENV PHP_INI_DIR /usr/local/etc/php
ENV PHP_URL "https://secure.php.net/get/php-${PHP_VERSION}.tar.xz/from/this/mirror"

ENV DEP_PACKAGES="\
argon2-dev libpng-dev freetype-dev libwebp-dev libjpeg-turbo-dev libxpm-dev libexif-dev \
curl-dev dpkg-dev imagemagick-dev gd-dev libzip-dev libc-dev musl-dev libedit-dev libsodium-dev \
libxml2-dev tidyhtml-dev sqlite-dev zlib-dev xmlrpc-c-dev libxslt-dev gettext-dev imap-dev openldap-dev icu-dev \
bzip2-dev libmcrypt-dev"

ENV PECL_EMBEDDED_PACKAGES="igbinary imagick mcrypt"
ENV PECL_MODULAR_PACKAGES="redis xdebug-2.7.0beta1"

RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories
RUN xargs apk add --no-cache ${DEP_PACKAGES}

RUN set -xe; \
	mkdir -p /usr/src; \
	cd /usr/src; \
	wget -O php.tar.xz "${PHP_URL}"; \
	tar -xvJf php.tar.xz; \
	ln -s php-"${PHP_VERSION}" php; \
	cd /usr/src/php/ext; \
	for i in ${PECL_EMBEDDED_PACKAGES}; do curl https://pecl.php.net/get/${i} | tar xvz; mv ${i}* ${i##*-}; done

RUN set -xe \
	&& export CFLAGS="${CUSTOM_CFLAGS}" \
		CPPFLAGS="${CUSTOM_CFLAGS}" \
		LDFLAGS="-Wl,-O1 -Wl,--hash-style=both -pie" \
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

FROM alpine

COPY --from=php-builder /usr/local/ /usr/local/

RUN runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/ \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories \
	&& apk add $runDeps

RUN set -x \
	&& addgroup -g 48 -S www-data \
	&& adduser -u 990 -D -S -G www-data www-data

CMD ["php-fpm"]
# ----------------------------------------------------------------------------------------------------------------------
# - Apache Build container Build Start -

FROM builder as apache-builder

ENV HTTPD_VERSION 2.4.38
ENV MODFCGID_VERSION 2.3.9
ENV APR_VERSION 1.6.5
ENV APRUTIL_VERSION 1.6.1
ENV PCRE_VERSION 8.42

ENV LIBEXPAT_URL https://github.com/libexpat/libexpat/releases/download/R_2_2_6/expat-2.2.6.tar.bz2

ENV HTTPD_URL http://www-eu.apache.org/dist/httpd/httpd-${HTTPD_VERSION}.tar.bz2
ENV MODFCGID_URL http://www-eu.apache.org/dist/httpd/mod_fcgid/mod_fcgid-${MODFCGID_VERSION}.tar.bz2
ENV APR_URL http://www-eu.apache.org/dist/apr/apr-${APR_VERSION}.tar.bz2
ENV APRUTIL_URL http://www-eu.apache.org/dist/apr/apr-util-${APRUTIL_VERSION}.tar.bz2
ENV PCRE_URL https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.bz2


RUN apk add --no-cache python

RUN set -xe; \
	mkdir -p /usr/src; \
	cd /usr/src; \
	curl $PCRE_URL | tar xvj; \
	ln -s pcre* pcre; \
    wget ${LIBEXPAT_URL} -O - | tar xvj; \
    ln -s expat* expat; \
    curl ${HTTPD_URL} | tar xvj; \
    ln -s httpd* httpd; \
    curl ${MODFCGID_URL} | tar xvj; \
    cp -r mod_fcgid-*/* httpd; \
    cd httpd/srclib; \
    curl ${APR_URL} | tar xvj; mv apr* apr;\
    curl ${APRUTIL_URL} | tar xvj; mv apr-util* apr-util

RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
	cd /usr/src/pcre; \
	./configure; \
	make -j $(nproc); \
	make install; \
	cd /usr/src/expat; \
	./configure; \
	make -j $(nproc); \
	make install; \
	cd /usr/src/httpd/; \
	./buildconf; \
	./configure --enable-fcgid; \
	make -j $(nproc); \
	make install

FROM alpine
COPY --from=apache-builder /usr/local/ /usr/local/

CMD ["httpd"]



# ----------------------------------------------------------------------------------------------------------------------
# - Modsecurity Image Build
# This will build a standalove Modsecurity image intended to be used as a SPOA backend for Haproxy.
# ----------------------------------------------------------------------------------------------------------------------


FROM lean-hap_builder as modsec-builder

# TODO: Would be nice to have something here to resolve latest versions automatically.
# -- ModSecurity version ----------------------------------------------------------------
ENV MODSEC_VERSION 2.9.3
# ---------------------------------------------------------------------------------------
# -- HAProxy version ----------------------------------------------------------------
ENV HAPROXY_VERSION 1.9.10
# ---------------------------------------------------------------------------------------

ENV MODSEC_URL https://www.modsecurity.org/tarball/${MODSEC_VERSION}/modsecurity-${MODSEC_VERSION}.tar.gz
ENV HAPROXY_URL http://www.haproxy.org/download/1.9/src/haproxy-${HAPROXY_VERSION}.tar.gz

# This will download all the files needed
RUN set -xe; \
    apk add --no-cache linux-headers apr-dev apache2-dev curl-dev libxml2-dev pcre-dev libevent-dev yajl-dev; \
	mkdir -p /usr/src; \
	cd /usr/src; \
    for i in ${MODSEC_URL} ${HAPROXY_URL}; \
    do curl ${i} | tar xvz; \
    done; \
    mv modsec* modsecurity; \
    git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git

# Build Modsec
RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/modsecurity; \
    ./autogen.sh && \
    ./configure --prefix=$PWD/INSTALL \
	  --disable-apache2-module \
      --enable-standalone-module \
      --enable-pcre-study \
      --without-lua \
      --enable-pcre-jit && \
    make -j $(nproc) && \
    make -C standalone install && \
    mkdir -p INSTALL/include && \
    cp standalone/*.h apache2/*.h INSTALL/include;

# Build HAProxy Modsec-spoa
RUN set -xe; \
	export CFLAGS="${CUSTOM_CFLAGS}"; \
	export CXXFLAGS="${CUSTOM_CFLAGS}"; \
    cd /usr/src/haproxy*/contrib/modsecurity; \
    make MODSEC_INC=/usr/src/modsecurity/INSTALL/include \
    MODSEC_LIB=/usr/src/modsecurity/INSTALL/lib \
    APACHE2_INC=/usr/include/apache2 \
    APR_INC=/usr/include/apr-1

FROM alpine:edge
COPY --from=modsec-builder /usr/src/haproxy*/contrib/modsecurity/modsecurity /sbin/
RUN apk add $(scanelf --needed --nobanner --format '%n#p' /sbin/modsecurity  | tr ',' '\n' | sed 's/^/so:/')

COPY --from=modsec-builder /usr/src/owasp-modsecurity-crs /etc/modsecurity/owasp-modsecurity-crs

RUN wget -qO/etc/modsecurity/modsecurity.conf https://github.com/SpiderLabs/ModSecurity/raw/v2/master/modsecurity.conf-recommended \
    && wget -qO/etc/modsecurity/unicode.mapping https://github.com/SpiderLabs/ModSecurity/raw/v2/master/unicode.mapping \
    && find \
            /etc/modsecurity/owasp-modsecurity-crs \
            -type f -name '*.example' \
        | while read -r f; do cp -p "$f" "${f%.example}"; done \
    && sed -i.example \
        's/^SecRuleEngine .*/SecRuleEngine On/' \
        /etc/modsecurity/modsecurity.conf \
    && sed -i.example \
        's/^\(SecDefaultAction "phase:[12]\),log,auditlog,pass"/\1,log,noauditlog,deny,status:403"/' \
        /etc/modsecurity/owasp-modsecurity-crs/crs-setup.conf \
    && find \
            /etc/modsecurity/owasp-modsecurity-crs \
            -type f -maxdepth 1 -name '*.conf' \
        | sort | sed 's/^/Include /' > /etc/modsecurity/owasp-modsecurity-crs.conf \
    && find \
            /etc/modsecurity/owasp-modsecurity-crs/rules \
            -type f -maxdepth 1 -name '*.conf' \
        | sort | sed 's/^/Include /' >> /etc/modsecurity/owasp-modsecurity-crs.conf


ENTRYPOINT [ "/sbin/modsecurity", "-p", "6666", "-f", "/etc/modsecurity/modsecurity.conf" ]
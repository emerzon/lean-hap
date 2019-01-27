FROM alpine as builder

ENV BUILD_PACKAGES="\
autoconf automake binutils ca-certificates cmake coreutils curl dpkg file git gcc g++ gmp gnupg isl libressl libtool make mpc1 \
mpfr3 pkgconf re2c tar wget xz"
ENV CUSTOM_CFLAGS "-fstack-protector-strong -fpie -O3 -march=native"

RUN sed -i -e 's/v[[:digit:]]\.[[:digit:]]/edge/g' /etc/apk/repositories
RUN apk add --no-cache ${BUILD_PACKAGES}

# In case you used the compiled GCC from gcc-builder you can uncomment below.
# COPY --from=gccbuilder /usr/local/ /usr/
# RUN ln -s /usr/bin/gcc /usr/bin/cc

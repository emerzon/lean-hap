FROM alpine:edge as builder

ENV BUILD_PACKAGES="\
autoconf automake binutils ca-certificates cmake coreutils curl dpkg file git gcc g++ gmp gnupg isl openssl libtool musl-dev \
make mpc1 mpfr3 pkgconf re2c tar wget xz"
ENV CUSTOM_CFLAGS "-O3 -march=native"

RUN apk add --no-cache ${BUILD_PACKAGES}

# In case you used the compiled GCC from gcc-builder you can uncomment below.
# COPY --from=lean-hap_gcc-builder /usr/local/ /usr/
# RUN ln -s /usr/bin/gcc /usr/bin/cc

FROM ubuntu:cosmic
ARG VERSION
ARG REL
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y

# Install build dependencies
RUN apt install -y binutils build-essential cmake debhelper dh-make gcc make
RUN mkdir /build
COPY v${VERSION}.tar.gz /build/aws-checksums_${VERSION}.orig.tar.gz
WORKDIR /build
RUN tar xf aws-checksums_${VERSION}.orig.tar.gz
RUN mv aws-checksums-${VERSION} aws-checksums_${VERSION}-${REL}
COPY debian /build/aws-checksums_${VERSION}-${REL}/debian/
COPY patches/* /build/aws-checksums_${VERSION}-${REL}/debian/patches/
RUN sed -e "s/@VERSION@/${VERSION}/g" \
    /build/aws-checksums_${VERSION}-${REL}/debian/substvars.in \
    > /build/aws-checksums_${VERSION}-${REL}/debian/substvars
WORKDIR /build/aws-checksums_${VERSION}-${REL}
RUN dpkg-checkbuilddeps
RUN dpkg-buildpackage
VOLUME /export

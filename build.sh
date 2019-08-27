#!/bin/bash -ex
ARCH=$(uname -m)
PACKAGE=aws-checksums
VERSION=0.1.3
REL=0
DOWNLOAD_URL="https://github.com/awslabs/aws-checksums/archive/v$VERSION.tar.gz"
EXPORT=/srv/dist.ionosphere.io

umask 002

if [[ ! -f v$VERSION.tar.gz ]]; then
    curl -s --location -o v$VERSION.tar.gz "$DOWNLOAD_URL"
fi

for TARGET in amzn1 amzn2 el7; do
	docker build -t build-${PACKAGE}:$TARGET \
		--build-arg VERSION=$VERSION \
		--build-arg REL=$REL \
		-f $TARGET.dockerfile .
	mkdir -p $EXPORT/$TARGET/SRPMS $EXPORT/$TARGET/RPMS/$ARCH
	docker run --rm --volume $EXPORT/${TARGET}:/export \
		build-${PACKAGE}:$TARGET \
	  	/bin/sh -c "cp /usr/src/rpm/SRPMS/* /export/SRPMS && cp /usr/src/rpm/RPMS/$ARCH/* /export/RPMS/$ARCH/"
done;

for TARGET in ubuntu-xenial ubuntu-bionic ubuntu-cosmic ubuntu-disco; do
	docker build -t build-${PACKAGE}:$TARGET \
		--build-arg VERSION=$VERSION \
		--build-arg REL=$REL \
		-f $TARGET.dockerfile .
	mkdir -p $EXPORT/$TARGET
	docker run --rm --volume $EXPORT/${TARGET}:/export \
		build-${PACKAGE}:$TARGET \
	  	/bin/bash -c "shopt -s nullglob; cp -f /build/*.deb /build/*.dsc /build/*.changes /build/*.debian.tar.* /build/*.orig.tar.* /build/*.buildinfo /export/"
done;

#!/usr/bin/env sh

# Set sources
PREFIX='apache-artemis'
RELEASE='2.5.0'
REPO="https://repository.apache.org/content/repositories/snapshots/org/apache/activemq/apache-artemis/${RELEASE}-SNAPSHOT/"
VERSION=$(wget -O - -o /dev/null $REPO/maven-metadata.xml | grep -oP '(?<=<value>).*?(?=</value>)' | head -1)
FILENAME="${PREFIX}-${VERSION}-bin.zip"
mkdir /opt && cd /opt
wget -q $REPO/${FILENAME}
wget -q $REPO/${FILENAME}.sha1
# Verify
sha1sum ${FILENAME} | grep $(cat ${FILENAME}.sha1)
# Unpack and create link
unzip ${FILENAME}
ln -s ${PREFIX}-${RELEASE}-SNAPSHOT A-MQ7
rm -rf ${FILENAME}
# Verify package @TODO

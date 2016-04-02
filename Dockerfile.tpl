FROM %DOCKER_REGISTRY%docker-library-alpine

# Thanks to:
# Anastas Dancha <anapsix@random.io>
# Vladimir Krivosheev <develar@gmail.com>
# and Victor Palma <palma.victor@gmail.com>

MAINTAINER Serge Fomin <serge.fo@gmail.com>

# https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk
COPY glibc-2.21-r2.apk /tmp/glibc-2.21-r2.apk
# https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk
COPY glibc-bin-2.21-r2.apk /tmp/glibc-bin-2.21-r2.apk

RUN apk update \
  && apk add ca-certificates \
  && apk add --allow-untrusted /tmp/glibc-2.21-r2.apk \
  && apk add --allow-untrusted /tmp/glibc-bin-2.21-r2.apk \
  && /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib

ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 74
ENV JAVA_VERSION_BUILD 02
ENV JAVA_PACKAGE server-jre
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:/opt/jdk/bin
ENV LANG C.UTF-8

RUN mkdir /opt

# curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o server-jre-8u74-linux-x64.tar.gz http://download.oracle.com/otn-pub/java/jdk/8u74-b02/server-jre-8u74-linux-x64.tar.gz
# RUN curl \
#   -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" \
#   -o ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
#   http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz

# Keeping jre package locally for offline/more predictable builds
ADD ${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz /opt


# Cleanup
RUN ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk \
  && find /opt/jdk/ -maxdepth 1 -mindepth 1 | grep -v jre | xargs rm -rf \
  && cd /opt/jdk \
  && ln -s ./jre/bin ./bin \
  && rm -rf /opt/jdk/jre/plugin \
    /opt/jdk/jre/bin/javaws \
    /opt/jdk/jre/bin/jjs \
    /opt/jdk/jre/bin/keytool \
    /opt/jdk/jre/bin/orbd \
    /opt/jdk/jre/bin/pack200 \
    /opt/jdk/jre/bin/policytool \
    /opt/jdk/jre/bin/rmid \
    /opt/jdk/jre/bin/rmiregistry \
    /opt/jdk/jre/bin/servertool \
    /opt/jdk/jre/bin/tnameserv \
    /opt/jdk/jre/bin/unpack200 \
    /opt/jdk/jre/lib/javaws.jar \
    /opt/jdk/jre/lib/deploy* \
    /opt/jdk/jre/lib/desktop \
    /opt/jdk/jre/lib/*javafx* \
    /opt/jdk/jre/lib/*jfx* \
    /opt/jdk/jre/lib/amd64/libdecora_sse.so \
    /opt/jdk/jre/lib/amd64/libprism_*.so \
    /opt/jdk/jre/lib/amd64/libfxplugins.so \
    /opt/jdk/jre/lib/amd64/libglass.so \
    /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
    /opt/jdk/jre/lib/amd64/libjavafx*.so \
    /opt/jdk/jre/lib/amd64/libjfx*.so \
    /opt/jdk/jre/lib/ext/jfxrt.jar \
    /opt/jdk/jre/lib/ext/nashorn.jar \
    /opt/jdk/jre/lib/oblique-fonts \
    /opt/jdk/jre/lib/plugin.jar \
    /tmp/* /var/cache/apk/* \
  && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

CMD java -version

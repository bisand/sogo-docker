FROM ubuntu:latest as build

ARG SOGO_VERSION=5.8.0
ARG BUILD_TZ="Europe/Oslo"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -qy --no-install-recommends \
        wget \
        gnustep-make \
        gnustep-base-common \
        libgnustep-base-dev \
        make \
        gobjc \
        libxml2-dev \
        libssl-dev \
        libldap2-dev \
        libmysqlclient-dev \
        libmemcached-dev \
        libsodium-dev \
        libcurl4-openssl-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*   

RUN echo $BUILD_TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$BUILD_TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata 

RUN echo "build SOPE-${SOGO_VERSION} ..." \
    && wget -q -O /tmp/SOPE-${SOGO_VERSION}.tar.gz https://codeload.github.com/Alinto/sope/tar.gz/SOPE-${SOGO_VERSION} \
    && tar -C  /tmp -xzf /tmp/SOPE-${SOGO_VERSION}.tar.gz \
    && mkdir -p /build && mv /tmp/sope-SOPE-${SOGO_VERSION}/* /build/. \
    && cd /build && ./configure --with-gnustep --enable-debug --disable-strip && make && make install \
    && rm -rf /tmp/* /build

# ugly unimock patch for change password in multidomain setup against postfixadmin mysql user_sogo view
RUN echo "build SOGo-${SOGO_VERSION} ..."  \
    && wget -q  -O /tmp/SOGo-${SOGO_VERSION}.tar.gz https://codeload.github.com/Alinto/sogo/tar.gz/SOGo-${SOGO_VERSION} \
    && tar -C  /tmp -xzf /tmp/SOGo-${SOGO_VERSION}.tar.gz \
    && mkdir -p /build && mv /tmp/sogo-SOGo-${SOGO_VERSION}/* /build/. \
    && cd /build && ./configure --enable-debug --disable-strip && make && make install \
    && rm -rf /tmp/* /build


# FROM ubuntu/nginx:latest
# RUN apt-get update && apt-get install -qy --no-install-recommends \
#       mysql-client \
#       inetutils-ping \
#       rsync \
#       tzdata \
#       wget \
#       cron \
#       supervisor \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*   

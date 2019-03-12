FROM alpine:3.8
MAINTAINER Wayne Humphrey <wayne@humphrey.za.net>

ENV HAPROXY_VERSION 1.9.4
ENV HAPROXY_URL https://www.haproxy.org/download/1.9/src/haproxy-1.9.4.tar.gz
ENV HAPROXY_SHA256 8483fe12b30256f83d542b3f699e165d8f71bf2dfac8b16bb53716abce4ba74f

# see https://sources.debian.net/src/haproxy/jessie/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN set -x \
	\
	&& apk upgrade && apk update \
	&& apk add --no-cache --virtual .build-deps \
		ca-certificates \
		gcc \
		libc-dev \
		linux-headers \
		lua5.3-dev \
		make \
		openssl \
		openssl-dev \
		pcre-dev \
		readline-dev \
		tar \
		zlib-dev \
	\
	&& wget -O haproxy.tar.gz "$HAPROXY_URL" \
	&& echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c \
	&& mkdir -p /usr/src/haproxy \
	&& tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
	&& rm haproxy.tar.gz \
	\
	&& makeOpts=' \
		TARGET=linux2628 \
		USE_LUA=1 LUA_INC=/usr/include/lua5.3 LUA_LIB=/usr/lib/lua5.3 \
		USE_OPENSSL=1 \
		USE_PCRE=1 PCREDIR= \
		USE_ZLIB=1 \
	' \
	&& make -C /usr/src/haproxy -j "$(getconf _NPROCESSORS_ONLN)" all $makeOpts \
	&& make -C /usr/src/haproxy install-bin $makeOpts \
	\
	&& rm -rf /usr/src/haproxy \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --virtual .haproxy-rundeps $runDeps \
	&& apk del .build-deps \
	\
	&& apk add rsyslog \
	certbot \
	bash \
	\
	&& mkdir -p /etc/rsyslog.d/ \
	&& touch /var/log/haproxy.log \
	&& ln -sf /dev/stdout /var/log/haproxy.log \
	&& mkdir /haproxy

# https://www.haproxy.org/download/1.8/doc/management.txt
# "4. Stopping and restarting HAProxy"
# "when the SIGTERM signal is sent to the haproxy process, it immediately quits and all established connections are closed"
# "graceful stop is triggered when the SIGUSR1 signal is sent to the haproxy process"
STOPSIGNAL SIGUSR1

ADD ./helper/errors/ /errors/
ADD ./helper/etc/ /etc/
ADD ./helper/haproxy/ /etc/haproxy/

ADD ./helper/entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT [ "entrypoint" ]

CMD [ "-f", "/etc/haproxy/global.cfg", "-f", "/etc/haproxy/stats.cfg", "-f", "/etc/haproxy/proxy.cfg" ]

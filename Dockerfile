FROM alpine:3.12.0
MAINTAINER Wayne Humphrey <wayne@humphrey.za.net>
ENV HAPROXY_URL https://www.haproxy.org/download/2.1/src/haproxy-2.1.2.tar.gz
ENV HAPROXY_SHA256 6079b08a8905ade5a9a2835ead8963ee10a855d8508a85efb7181eea2d310b77

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
		TARGET=linux-glibc \
		USE_LUA=1 \
		LUA_INC=/usr/include/lua5.3 \
		LUA_LIB=/usr/lib/lua5.3 \
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
	mini_httpd \
	\
	&& mkdir -p /etc/rsyslog.d/ \
	&& touch /var/log/haproxy.log \
	&& ln -sf /dev/stdout /var/log/haproxy.log \
	&& mkdir /haproxy \
	&& rm -Rf /etc/mini_httpd/

STOPSIGNAL SIGUSR1

ADD ./helper/errors/ /errors/
ADD ./helper/etc/ /etc/
ADD ./helper/haproxy/ /etc/haproxy/
ADD ./helper/www/ /www/

ADD ./helper/entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT [ "entrypoint" ]

CMD [ "-f", "/etc/haproxy/global.cfg", "-f", "/etc/haproxy/stats.cfg", "-f", "/etc/haproxy/proxy.cfg" ]

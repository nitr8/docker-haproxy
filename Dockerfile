FROM alpine:3.16.2
MAINTAINER Wayne Humphrey <wayne@humphrey.za.net>
ENV HAPROXY_URL https://www.haproxy.org/download/2.6/src/haproxy-2.6.6.tar.gz
ENV HAPROXY_SHA256 d0c80c90c04ae79598b58b9749d53787f00f7b515175e7d8203f2796e6a6594d

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk update
RUN apk add libexecinfo-dev@edge

RUN set -x \
	\
	&& echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
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
  && make -C /usr/src/haproxy -j $(nproc) TARGET=linux-glibc USE_OPENSSL=1 USE_LUA=1 USE_PCRE=1 LUA_INC=/usr/include/lua5.3 LUA_LIB=/usr/lib/lua5.3 USE_ZLIB=1 \
	&& make -C /usr/src/haproxy install-bin \
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
ADD ./certs/wildcard.pem /certs/wildcard.pem

ADD ./helper/entrypoint.sh /bin/entrypoint
RUN chmod +x /bin/entrypoint
ENTRYPOINT [ "entrypoint" ]

CMD [ "-f", "/etc/haproxy/global.cfg", "-f", "/etc/haproxy/stats.cfg", "-f", "/etc/haproxy/proxy.cfg" ]

FROM nginx:1.24-bullseye

MAINTAINER Alif Bintoro <alifbintoro77@gmail.com>
LABEL org.opencontainers.image.source=https://github.com/alifbint/nginx-modsec

RUN apt update
RUN apt install software-properties-common tar wget dpkg-dev git gcc make build-essential \
	autoconf automake libtool libcurl4-openssl-dev liblua5.3-dev libpcre2-dev \
	libfuzzy-dev ssdeep gettext pkg-config libpcre3 libpcre3-dev libxml2 libxml2-dev libcurl4 \
	libgeoip-dev libyajl-dev doxygen -y
RUN mkdir -p /usr/local/src/nginx
RUN cd /usr/local/src/nginx/ \
	&& wget http://nginx.org/download/nginx-1.24.0.tar.gz -P /usr/local/src/nginx \
	&& tar xvf /usr/local/src/nginx/nginx-1.24.0.tar.gz -C /usr/local/src/nginx

RUN git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/ \
	&& cd /usr/local/src/ModSecurity/ \
	&& git submodule init \
	&& git submodule update \
	&& ./build.sh \
	&& ./configure \
	&& make -j4 \
	&& make install

RUN git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/

RUN echo "deb-src http://deb.debian.org/debian/ bullseye main" >> /etc/apt/sources.list \
	&& echo "deb-src http://security.debian.org/debian-security/ bullseye-security main" >> /etc/apt/sources.list \
	&& apt update

RUN cd /usr/local/src/nginx/nginx-1.24.0/ \
	&& apt build-dep nginx -y \
	&& apt install uuid-dev -y \
	&& ./configure --with-compat --with-openssl=/usr/include/openssl/ --add-dynamic-module=/usr/local/src/ModSecurity-nginx \
	&& make modules \
	&& cp objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/

RUN echo -e "/var/log/modsec_audit.log\n{\n\trotate 14\n\tdaily\n\tmissingok\n\tcompress\n\tdelaycompress\n\tnotifempty\n}" > /etc/logrotate.d/modsecurity

RUN git clone --depth 1 --recurse-submodules -j8 https://github.com/google/ngx_brotli /usr/local/src/ngx_brotli/ \
	&& cd /usr/local/src/nginx/nginx-1.24.0/ \
	&& ./configure --with-compat --add-dynamic-module=/usr/local/src/ngx_brotli \
	&& make modules \
	&& cp objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/ \
	&& cp objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/

COPY nginx/conf.d /etc/nginx/conf.d
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/modsec /etc/nginx/modsec
COPY nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY nginx/mime.types /etc/nginx/mime.types
FROM alpine

WORKDIR /tmp

RUN set -eux \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
        libedit-dev \
        mercurial \
        bash \
        alpine-sdk \
        findutils \
        unzip \
    && wget https://nginx.org/download/nginx-1.25.1.tar.gz \
    && tar -zxvf nginx-1.25.1.tar.gz \
    && rm -f nginx-1.25.1.tar.gz \
    && wget https://github.com/chobits/ngx_http_proxy_connect_module/archive/refs/tags/v0.0.5.tar.gz \
    && tar -zxvf v0.0.5.tar.gz \
    && rm -f v0.0.5.tar.gz \
    && cd nginx-1.25.1 \
    && patch -p1 < ../ngx_http_proxy_connect_module-0.0.5/patch/proxy_connect_rewrite_102101.patch \
    && ./configure \
        --user=nginx \
        --group=nginx \
        --prefix=/var/www/html \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --with-pcre  \
        --lock-path=/var/lock/nginx.lock \
        --pid-path=/var/run/nginx.pid \
        --with-http_ssl_module \
        --with-http_image_filter_module \
        --with-http_geoip_module \
        --with-http_v2_module \
        --with-http_addition_module \
        --with-http_stub_status_module \
        --with-http_mp4_module \
        --with-http_realip_module \
        --with-http_auth_request_module \
        --with-http_sub_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
	--with-http_v3_module \
	--with-mail \
        --with-stream \
        --with-debug \
        --with-cc-opt='-O0 -g' \
        --with-threads \
        --with-file-aio \
        --modules-path=/etc/nginx/modules \
        --add-module=../ngx_http_proxy_connect_module-0.0.5 \
    && make \
    && make install \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p /etc/nginx/ssl \
    && cd ../ \
    && rm -rf /tmp/* \
    && apk del .build-deps \
    && apk add --no-cache \
        curl \
        ca-certificates \
        tzdata \
        pcre


WORKDIR /var/www

ENTRYPOINT ["nginx", "-g", "daemon off;"]

EXPOSE 80 443

STOPSIGNAL SIGQUIT

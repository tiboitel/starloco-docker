FROM php:8.3-fpm-alpine

RUN apk add --no-cache \
    nginx \
    curl \
    bash \
    php83 \
    php83-fpm \
    php83-session \
    php83-pdo \
    php83-pdo_mysql \
    php83-mysqli \
    php83-mbstring \
    php83-gd \
    php83-zip \
    php83-opcache \
    php83-intl \
    php83-curl \
    php83-json \
    mariadb-client

RUN mkdir -p /var/www/web /var/www/adminer /var/www/dofus /var/www/data /run/php /var/log/nginx

RUN set -eux; \
    for conf in /etc/php83/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf; do \
        if [ -f "$conf" ]; then \
            sed -i 's/^user = .*/user = www-data/' "$conf"; \
            sed -i 's/^group = .*/group = www-data/' "$conf"; \
        fi; \
    done

COPY php.ini /usr/local/etc/php/php.ini
COPY nginx.conf /etc/nginx/nginx.conf
COPY healthz.html /usr/local/share/nginx/html/healthz.html

RUN chown -R www-data:www-data /var/www

EXPOSE 80

CMD ["sh", "-c", "php-fpm83 & nginx -g 'daemon off;'"]

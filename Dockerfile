
FROM php:7.3-fpm-alpine

MAINTAINER hanhan1978 <ryo.tomidokoro@gmail.com>

# install libraries
RUN apk upgrade --update \
    && apk add --no-cache \
       git zlib-dev nginx libxml2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql zip soap \
    && mkdir /run/nginx

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY laravel/composer.json /tmp/composer.json
COPY laravel/composer.lock /tmp/composer.lock
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN composer install --no-scripts --no-autoloader -d /tmp

COPY ./var/conf/nginx.conf /etc/nginx/nginx.conf

COPY laravel /var/www/laravel

WORKDIR /var/www/laravel

RUN mv -n /tmp/vendor ./ \
  && composer dump-autoload

RUN chown www-data:www-data storage/logs \
    && chown -R www-data:www-data storage/framework \
    && cp .env.example .env \
    && php artisan key:generate \
    && mkdir -p  /usr/share/nginx \
    && ln -s /var/www/laravel/public /usr/share/nginx/html

COPY ./run.sh /usr/local/bin/run.sh

CMD ["run.sh"]

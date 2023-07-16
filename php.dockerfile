FROM php:8.1.4-fpm-alpine3.15

ADD ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN addgroup -g 1000 laravel && adduser -G laravel -g laravel -s /bin/sh -D laravel

RUN apk update; \
    apk upgrade;

RUN apk add libzip-dev
RUN docker-php-ext-install zip

RUN apk add --no-cache libpng libpng-dev && \
    docker-php-ext-install gd && \
    apk del libpng-dev

RUN docker-php-ext-install mysqli pdo pdo_mysql

RUN apk add --no-cache pcre-dev $PHPIZE_DEPS && \
    pecl update-channels && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    apk del $PHPIZE_DEPS

# RUN pecl install -o -f redis \
#     && rm -rf /tmp/pear \
#     && docker-php-ext-enable redis

# Install required dependencies
# RUN apt-get update && apt-get install -y \
#     zlib1g-dev \
#     libzip-dev \
#     && rm -rf /var/lib/apt/lists/*

# Install Redis extension
#RUN pecl install redis && docker-php-ext-enable redis


RUN mkdir -p /var/www/html

RUN chown laravel:laravel /var/www/html

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql
# Install Redis extension
#RUN pecl install redis 
#RUN docker-php-ext-enable redis

# Add xdebug
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS
RUN apk add --update linux-headers
RUN pecl install xdebug-3.1.5
RUN docker-php-ext-enable xdebug
RUN apk del -f .build-deps

# Configure Xdebug
RUN echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.discover_client_host=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/xdebug.ini

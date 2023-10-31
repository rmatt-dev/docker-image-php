ARG INTERFACE=cli
ARG PHP_VERSION
ARG PECL_REDIS_VERSION

FROM php:$PHP_VERSION-$INTERFACE-alpine3.18 as base
ARG INTERFACE
ARG PECL_REDIS_VERSION

ENV APP_UID 20000
ENV APP_GID 20000
ENV APP_USER sfvuedev
ENV APP_GROUP sfvuedev
ENV APP_DOCKER_INTERFACE $INTERFACE

RUN apk add --no-cache \
    $PHPIZE_DEPS \
    bash \
    coreutils \
    tzdata \
    libzip-dev \
    ca-certificates \
    icu-dev \
    icu-libs \
    icu-data-full \
    gnu-libiconv \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    postgresql-dev \
    sqlite \
    && pecl install -o -f redis-$PECL_REDIS_VERSION \
    && docker-php-ext-install -j$(nproc) intl pdo_pgsql zip gd \
    && docker-php-ext-configure gd --with-jpeg=/usr/lib/ \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable opcache \
    && echo "Etc/UTC" > /etc/timezone \
    && apk del $PHPIZE_DEPS

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

COPY resources/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN addgroup --gid $APP_GID -S $APP_GROUP \
    && adduser --uid $APP_UID -S $APP_USER -G $APP_GROUP

USER $APP_USER:$APP_GROUP

ENTRYPOINT ["docker-entrypoint.sh"]
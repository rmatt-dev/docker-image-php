ARG VARIANT=base
ARG APP_ENV
ARG REPOSITORY_URL
ARG VERSION
ARG PHP_INI_VARIANT=production
ARG XDEBUG_VARSION
ARG COMPOSER_VERSION

FROM ${REPOSITORY_URL}/php8.2:$VERSION-base-cli as base
ARG APP_ENV

FROM base as base-dev
ARG XDEBUG_VERSION
ARG COMPOSER_VERSION
ARG APP_ENV

ENV COMPOSER_ALLOW_SUPERUSER 1

USER root

RUN apk add --no-cache $PHPIZE_DEPS \
    git \
    openssh-client \
    && apk add --update linux-headers \
    && pecl install xdebug-$XDEBUG_VERSION \
    && docker-php-ext-enable xdebug \
    && apk del $PHPIZE_DEPS

RUN mkdir -p /composer \
    && cd /composer \
    && EXPECTED_CHECKSUM=$(wget -q -O - https://composer.github.io/installer.sig) \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && ACTUAL_CHECKSUM=$(php -r "echo hash_file('sha384', 'composer-setup.php');") \
    && if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then >&2 echo "ERROR: Invalid installer checksum [$EXPECTED_CHECKSUM] [$ACTUAL_CHECKSUM]"; rm composer-setup.php; exit 1; fi \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=$COMPOSER_VERSION \
    && chmod +x /usr/local/bin/composer \
    && rm -rf /composer

COPY resources/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini

FROM base-dev as symfony-dev
ARG APP_ENV

RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony5/bin/symfony /usr/local/bin/symfony \
    && chmod +x /usr/local/bin/symfony

COPY resources/symfony-entrypoint.sh /docker-entrypoint.sh

FROM $VARIANT
ARG APP_ENV
ARG PHP_INI_VARIANT

ENV APP_ENV $APP_ENV

USER root

RUN mv $PHP_INI_DIR/php.ini-$PHP_INI_VARIANT $PHP_INI_DIR/php.ini
COPY resources/php.ini-${PHP_INI_VARIANT} $PHP_INI_DIR/conf.d/z-base.ini

USER $APP_USER:$APP_GROUP

CMD ["php", "-a"]
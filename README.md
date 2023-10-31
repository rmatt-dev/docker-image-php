# Base PHP 8.2 images
* Images based on Alpine Linux
* mb_string, openssl, sqllite, curl enabled by default
* redis and opcache extensions on-board
* UTC as default timezone
* Extended localization support (ICU + Intl)
* ca-certificates and docker-root-certs
* sfvuedev user and sfvuedev group (20000:20000)
* Alternative, {dev, symfony} images, with xdebug onboard and composer

## Image building
The image is built on the CI server (). Manual approval is required before pushing the image into the registry.

Images can be build locally by running `buildAndDeploy.sh build <version>`.

### Created artifacts
* $REGISTRY_URL/php8.2:<version>-fpm-dev
* $REGISTRY_URL/php8.2:<version>-fpm
* $REGISTRY_URL/php8.2:<version>-cli-dev
* $REGISTRY_URL/php8.2:<version>-cli-symfony
* $REGISTRY_URL/php8.2:<version>-cli
* $REGISTRY_URL/php8.2:<version>

### php.ini configs
- Images built with `PHP_INI_VARIANT` argument set to `development` uses default `php.ini-development` (as main `php.ini`) and custom `php.ini-development` (as `conf.d/z-base.ini`)
- Images built with `PHP_INI_VARIANT` argument set to `production` uses default `php.ini-production` (as main `php.ini`) and custom `php.ini-production` (as `conf.d/z-base.ini`)

## Examples

### Local environment (cli) + production variant of configuration + custom xdebug config
docker-compose:
```yaml
php:
    image: eu.gcr.io/ckpl-reg/php8.2:<version>-cli-xdebug
    environment:
      - XDEBUG_CONFIG
      - XDEBUG_MODE
      - XDEBUG_SESSION
```

Up command:
```bash
XDEBUG_CONFIG="client_host=$(hostname -I | cut -d' ' -f1) start_with_request=yes log_level=0" \
XDEBUG_SESSION="PHPSTORM" \
docker-compose up
```

---
**TIP**

`APP_NAME` env - used to set the `service` field for fpm logs - should be passed as fastcgi parameter.

---

## Images

* **FPM (default php.ini-production + resource/php.ini-production)**: eu.gcr.io/ckpl-reg/php8.2:<version>-fpm
* **CLI (default php.ini-production + resource/php.ini-production)**: eu.gcr.io/ckpl-reg/php8.2:<version>-cli
* **FPM for dev (default php.ini-development + resource/php.ini-development + resource/xdebug.ini)**: eu.gcr.io/ckpl-reg/php8.2:<version>-fpm-dev
* **CLI for dev (default php.ini-development + resource/php.ini-development + resource/xdebug.ini)**: eu.gcr.io/ckpl-reg/php8.2:<version>-cli-dev
* **CLI with symfony (default php.ini-development + resource/php.ini-development + resource/xdebug.ini)**: eu.gcr.io/ckpl-reg/php8.2:<version>-cli-symfony

[CHANGELOG.md](CHANGELOG.md)

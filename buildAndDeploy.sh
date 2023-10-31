#!/bin/bash
set -xe

set -a
source versions.env
set +a

if [ -z ${2+x} ]; then
    echo -e "You must specify second (version) parameter.";
    exit 1;
fi
VERSION=${2}

if [ -z ${3+x} ]; then
    echo -e "You must specify thirty (repository url) parameter.";
    exit 1;
fi
REPOSITORY_URL=${3}

START_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ./src/php8.2/ || exit 1
if [ "$1" = "build" ]; then
    echo '\033[0;34m--- Build base php cli image...\033[0m'
    # base for cli
    docker build \
      --build-arg INTERFACE=cli \
      --build-arg PHP_VERSION=$DOCKER_PHP_IMAGE_VERSION \
      --build-arg PECL_REDIS_VERSION=$PECL_REDIS_VERSION \
      -f base/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-base-cli" \
      .

    echo '\033[0;34m--- Build final php cli image...\033[0m'
    # final cli
    docker build \
      --build-arg VERSION="${VERSION}" \
      --build-arg VARIANT=base \
      --build-arg APP_ENV=prod \
      --build-arg XDEBUG_VERSION=$XDEBUG_VERSION \
      --build-arg COMPOSER_VERSION=$COMPOSER_VERSION \
      --build-arg REPOSITORY_URL=$REPOSITORY_URL \
      -f cli/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-cli" \
      .
    echo '\033[0;34m--- Tagging final php cli image as base image for this version ...\033[0m'
    docker tag $REPOSITORY_URL/php8.2:"${VERSION}-cli" $REPOSITORY_URL/php8.2:"${VERSION}"

    echo '\033[0;34m--- Build final php cli image for dev environment...\033[0m'
    # final cli extended with xdebug, composer
    docker build \
      --build-arg VERSION="${VERSION}" \
      --build-arg VARIANT=base-dev \
      --build-arg PHP_INI_VARIANT=development \
      --build-arg APP_ENV=dev \
      --build-arg REPOSITORY_URL=$REPOSITORY_URL \
      --build-arg XDEBUG_VERSION=$XDEBUG_VERSION \
      --build-arg COMPOSER_VERSION=$COMPOSER_VERSION \
      -f cli/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-cli-dev" \
      .

    echo '\033[0;34m--- Build final php cli image with symfony cli for dev environment...\033[0m'
    # final cli extended with xdebug, composer, symfony
    docker build \
      --build-arg VERSION="${VERSION}" \
      --build-arg VARIANT=symfony-dev \
      --build-arg PHP_INI_VARIANT=development \
      --build-arg APP_ENV=dev \
      --build-arg REPOSITORY_URL=$REPOSITORY_URL \
      --build-arg XDEBUG_VERSION=$XDEBUG_VERSION \
      --build-arg COMPOSER_VERSION=$COMPOSER_VERSION \
      -f cli/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-cli-symfony" \
      .

    echo -e '\033[0;34m--- Build base php fpm image... ---\033[0m'
    # base for fpm
    docker build \
      --build-arg INTERFACE=fpm \
      --build-arg PHP_VERSION=$DOCKER_PHP_IMAGE_VERSION \
      --build-arg PECL_REDIS_VERSION=$PECL_REDIS_VERSION \
      -f base/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-base-fpm" \
      .

    echo '\033[0;34m--- Build final php fpm image...\033[0m'
    # final fpm
    docker build \
      --build-arg VERSION="${VERSION}" \
      --build-arg VARIANT=base \
      --build-arg APP_ENV=prod \
      --build-arg REPOSITORY_URL=$REPOSITORY_URL \
      --build-arg XDEBUG_VERSION=$XDEBUG_VERSION \
      --build-arg COMPOSER_VERSION=$COMPOSER_VERSION \
      -f fpm/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-fpm" \
      .

    echo '\033[0;34m--- Build final php fpm image for dev environment...\033[0m'
    # final fpm for dev
    docker build \
      --build-arg VERSION="${VERSION}" \
      --build-arg VARIANT=base-dev \
      --build-arg APP_ENV=dev \
      --build-arg PHP_INI_VARIANT=development \
      --build-arg REPOSITORY_URL=$REPOSITORY_URL \
      --build-arg XDEBUG_VERSION=$XDEBUG_VERSION \
      --build-arg COMPOSER_VERSION=$COMPOSER_VERSION \
      -f fpm/Dockerfile \
      -t $REPOSITORY_URL/php8.2:"${VERSION}-fpm-dev" \
      .
fi

if [ "$1" = "push" ]; then
  docker push $REPOSITORY_URL/php8.2:"${VERSION}"
  docker push $REPOSITORY_URL/php8.2:"${VERSION}-cli"
  docker push $REPOSITORY_URL/php8.2:"${VERSION}-cli-dev"
  docker push $REPOSITORY_URL/php8.2:"${VERSION}-cli-symfony"
  docker push $REPOSITORY_URL/php8.2:"${VERSION}-fpm"
  docker push $REPOSITORY_URL/php8.2:"${VERSION}-fpm-dev"
fi

cd "$START_DIR" || exit 1
exit 0
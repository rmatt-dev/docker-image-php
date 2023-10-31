#!/bin/sh
set -xe

symfony server:start -d --no-tls --document-root=public --dir=/var/www/html

exec /usr/local/bin/docker-php-entrypoint "$@"
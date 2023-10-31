#!/bin/sh

GCP_PROJECT_ID_TMP=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavour: Google")
export GCP_PROJECT_ID="${GCP_PROJECT_ID:=-}"
echo "GCP_PROJECT_ID set to: $GCP_PROJECT_ID"

exec /usr/local/bin/docker-php-entrypoint "$@"
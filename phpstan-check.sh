#!/bin/sh
set -e
cd "$(dirname "$0")"

# run tests
docker-compose exec -u webuser workspace ./vendor/bin/phpstan analyse app

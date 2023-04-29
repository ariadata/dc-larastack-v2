#!/bin/bash
cd "$(dirname "$0")"
docker-compose up -d
docker-compose exec -u webuser supervisor supervisorctl stop laravel-schedule laravel-short-schedule laravel-horizon
docker-compose exec -u webuser workspace php artisan down
docker-compose exec -u webuser workspace php artisan route:clear
docker-compose exec -u webuser workspace php artisan config:clear
cd ./src/
git reset --hard
git clean -f -d
git pull
# git checkout main
cd ../

docker-compose exec -u webuser workspace composer update
# docker-compose exec -u webuser -T workspace composer install --no-dev --no-interaction
docker-compose exec -u webuser workspace npm install
docker-compose exec -u webuser workspace npm run build
# docker-compose exec php composer update -q --no-ansi --no-interaction --no-scripts --no-progress --prefer-dist

# php artisan migrate
docker-compose exec -u webuser workspace php artisan migrate --force
docker-compose exec -u webuser workspace php artisan db:seed --force

# cache functions
# docker-compose exec -u webuser workspace php artisan config:cache
# docker-compose exec -u webuser workspace php artisan route:cache

# todo : Other laravel cache here
# ###

docker-compose exec -u webuser supervisor supervisorctl start laravel-schedule laravel-short-schedule laravel-horizon
docker-compose exec -u webuser workspace php artisan up

#!/bin/sh
set -e
cd "$(dirname "$0")"

docker-compose down
docker-compose pull
docker-compose up -d
docker-compose exec -u webuser workspace composer update
docker-compose exec -u webuser workspace php artisan key:generate
docker-compose exec -u webuser workspace php artisan migrate:fresh --force
docker-compose exec -u webuser workspace php artisan db:seed --force
docker-compose exec -u webuser workspace php artisan storage:link
docker-compose exec -u webuser workspace php artisan route:cache
docker-compose exec -u webuser workspace php artisan config:cache
docker-compose exec -u webuser workspace php artisan view:cache
docker-compose exec -u webuser workspace php artisan optimize
# docker-compose exec -u webuser workspace php artisan queue:restart
# docker-compose exec -u webuser workspace php artisan queue:work --daemon

# install npm packages
docker-compose exec -u webuser workspace npm install
docker-compose exec -u webuser workspace npm run build
# run tests
docker-compose exec -u webuser workspace ./vendor/bin/pest

docker-compose exec -u webuser supervisor supervisorctl restart all

# echo done message with green color that stack is ready
echo -e "\e[32mDone! Your stack is ready!\033[0m\nNow you can visit \e[33mhttp://localhost\033[0m to see your app.\n"

# ask user witch command do you want tu use , and put in inside $COMMAND variable
# put in $COMMAND inside this : docker-compose exec workspace su webuser -c 'here!'
read -p "Do you want to run a command inside the container? [y/N] " -n 1 -r

# set this to bash_alias file to run commands inside stack with larastack command


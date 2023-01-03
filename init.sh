#!/bin/sh
set -e
cd "$(dirname "$0")"

# ############################################## start vars and functions
SYSTEM_DEFAULT_TIMEZONE="$(cat /etc/timezone)"
STACK_UID="$(id -u)"
STACK_GID="$(id -g)"


# ############################################## end vars and functions
# ############################################## Start Questions
# get project name
read -e -p $'Enter \e[33mStack-Name\033[0m (no spaces!):\n' -i "larastack" DC_COMPOSE_PROJECT_NAME

# get default timezone for stack
read -e -p $'Enter \e[33mdefault timezone\033[0m for stack :\n' -i $SYSTEM_DEFAULT_TIMEZONE STACK_DEFAULT_TZ

# get environment type
## NOT used in this version
read -e -p $'Enter \e[33mEnvironment type [local,production]\033[0m for stack :\n' -i "local" STACK_ENV_TYPE

# get laravel starter-kit type
read -e -p $'Enter Laravel Type \e[33m[basic,jetstream]\033[0m for stack :\n' -i "jetstream" STACK_LARAVEL_TYPE

if [ "$STACK_ENV_TYPE" = "local" ]; then
	# nginx + pma port
	read -e -p $'Enter \e[33mnginx http port\033[0m for stack :\n' -i "8051" STACK_NGINX_HTTP_PORT
	read -e -p $'Enter \e[33mnginx https port\033[0m for stack :\n' -i "8052" STACK_NGINX_HTTPS_PORT
	read -e -p $'Enter \e[33mPHPMyAdmin http port\033[0m for stack :\n' -i "8082" STACK_PHPMYADMIN_HTTP_PORT
	read -e -p $'Enter \e[33mLaravel Vite port\033[0m for stack :\n' -i "5173" STACK_LARAVEL_VITE_PORT
fi

# ############################################## 
git clone 'https://github.com/ariadata/dc-larastack-v2-laravel-'$STACK_LARAVEL_TYPE'.git' src
rm -rf ./src/.git

mkdir -p ./data/{mongo,mysql,pgsql,redis}
# chmod 750 ./data/pgsql
cp .env.example .env
cp ./src/.env.example ./src/.env

# set compose_project_name .env
sed -i "s|COMPOSE_PROJECT_NAME=.*|COMPOSE_PROJECT_NAME=$DC_COMPOSE_PROJECT_NAME|g" .env

# set UID/GID to .env
sed -i "s|UID=.*|UID=$STACK_UID|g" .env && sed -i "s|GID=.*|GID=$STACK_GID|g" .env

# set Default time zone in .env and /src/.env and php_overrides
sed -i "s|DC_TZ=.*|DC_TZ=\"$STACK_DEFAULT_TZ\"|g" .env
sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=\"$STACK_DEFAULT_TZ\"|g" ./src/.env
sed -i "s|php_value\[date.timezone\] \=.*|php_value\[date.timezone\] \= $STACK_DEFAULT_TZ|g" ./configs/php/www.conf

# rm -rf .dev .git
rm -rf .dev .git

## check if production
if [ "$STACK_ENV_TYPE" = "production" ]; then
	mv production.yml.example docker-compose.yml
	
	sed -i "s|APP_ENV=.*|APP_ENV=production|g" ./src/.env
	sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|g" ./src/.env
	docker-compose up -d
	sleep 5
	# docker-compose exec -u webuser workspace composer install --optimize-autoloader --no-dev
	docker-compose exec -u webuser workspace composer update -q --no-dev --optimize-autoloader

	docker-compose exec -u webuser workspace php artisan key:generate
	echo -e "Waiting for MySQL to run migrations...\n"
	docker-compose exec -u webuser workspace php artisan migrate:fresh --force
	# sleep 5
	## check if is jetstream
	if [ "$STACK_LARAVEL_TYPE" = "jetstream" ]; then
		docker-compose exec -u webuser workspace npm install
		docker-compose exec -u webuser workspace npm run build
	fi
else
	mv local.yml.example docker-compose.yml
	
	# set http port for nginx and phpmyadmin
	sed -i "s|DC_PHPMYADMIN_HTTP_PORT=.*|DC_PHPMYADMIN_HTTP_PORT=$STACK_PHPMYADMIN_HTTP_PORT|g" .env
	sed -i "s|DC_NGINX_HTTP_PORT=.*|DC_NGINX_HTTP_PORT=$STACK_NGINX_HTTP_PORT|g" .env
	sed -i "s|DC_NGINX_HTTPS_PORT=.*|DC_NGINX_HTTPS_PORT=$STACK_NGINX_HTTPS_PORT|g" .env
	sed -i "s|DC_LARAVEL_VITE_PORT=.*|DC_LARAVEL_VITE_PORT=$STACK_LARAVEL_VITE_PORT|g" .env
	
	sed -i "s|autostart=.*|autostart=false|g" ./configs/supervisor/laravel.conf
	
	docker-compose up -d
	sleep 5
	docker-compose exec -u webuser workspace composer update

	docker-compose exec -u webuser workspace php artisan key:generate
	echo -e "Waiting for MySQL to run migrations...\n"
	docker-compose exec -u webuser workspace php artisan migrate:fresh --force
	# sleep 5
	docker-compose exec -u webuser workspace ./vendor/bin/pint

	## check if is jetstream
	if [ "$STACK_LARAVEL_TYPE" = "jetstream" ]; then
		docker-compose exec -u webuser workspace npm install
		docker-compose exec -u webuser workspace npm run build
	fi

fi

docker-compose exec -u webuser workspace ./vendor/bin/pest
docker-compose exec -u webuser supervisor supervisorctl restart all

clear
echo -e $'\n=====================================\n\e[32m First step of '$DC_COMPOSE_PROJECT_NAME' complete.\033[0m\n'
echo -e "\e[35mNow add aliases and run other initial commands from documents\033[0m\n\n"
echo -e "at the end of setup : \nWeb access : http://localhost:$STACK_NGINX_HTTP_PORT\n"
echo -e "PMA access : http://localhost:$STACK_PHPMYADMIN_HTTP_PORT\n\n"
echo -e "You can see other configs and ports in docker-compose file\n"
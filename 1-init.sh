#!/bin/sh
set -e
cd "$(dirname "$0")"

SYSTEM_DEFAULT_TIMEZONE="$(cat /etc/timezone)"
STACK_UID="$(id -u)"
STACK_GID="$(id -g)"

#if ! command -v git &> /dev/null
#then
#    echo "git could not be found, please install it first."
#    echo "sudo apt install git or sudo yum install git"
#    exit
#fi

# ############################################## start getting vars
# get project name
read -e -p $'Enter \e[33mStack-Name\033[0m (no spaces!):\n' -i "larastack" DC_COMPOSE_PROJECT_NAME

# get default timezone for stack
read -e -p $'Enter \e[33mdefault timezone\033[0m for stack :\n' -i $SYSTEM_DEFAULT_TIMEZONE STACK_DEFAULT_TZ

# get php version
read -e -p $'Enter \e[33mPHP-Version\033[0m (7.4, 8.0, 8.1, 8.2):\n' -i "8.2" STACK_PHP_VERSION

# get stack network_name
read -e -p $'Enter \e[33mStack Network-Name\033[0m (no spaces!):\n' -i "larastack-network" DC_NETWORK_NAME

# ############################################## end getting vars
rm -rf .git .dev
mkdir -p ./data/{mongo,mysql,pgsql,redis}

# create .env file
cp .env.example .env

# create src folder and copy .env.example to src/.env
git clone --depth=1 --branch=main https://github.com/ariadata/dc-larastack-v2-laravel-basic.git src
rm -rf ./src/.git
cp ./src/.env.example ./src/.env

# set project name to .env.example
sed -i "s|COMPOSE_PROJECT_NAME=.*|COMPOSE_PROJECT_NAME=\"$DC_COMPOSE_PROJECT_NAME\"|g" .env

# set UID/GID to .env.example
sed -i "s|UID=.*|UID=$STACK_UID|g" .env && sed -i "s|GID=.*|GID=$STACK_GID|g" .env

# set timezone to .env.example and www.conf
sed -i "s|DC_TZ=.*|DC_TZ=\"$STACK_DEFAULT_TZ\"|g" .env
sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=\"$STACK_DEFAULT_TZ\"|g" ./src/.env
sed -i "s|php_value\[date.timezone\] \=.*|php_value\[date.timezone\] \= $STACK_DEFAULT_TZ|g" ./configs/php/www.conf

# set php version to .env.example
sed -i "s|DC_PHP_VERSION=.*|DC_PHP_VERSION=$DC_PHP_VERSION|g" .env

mv docker-compose.yml.example docker-compose.yml

# replace "larastack-network-changeme" with $DC_NETWORK_NAME in docker-compose.yml
sed -i "s|larastack-network-changeme|$DC_NETWORK_NAME|g" docker-compose.yml

# Ask user witch services do you want from these (mysql, pgsql) , and remove the other from docker-compose.yml file
# if user choose something else than mysql or pgsql , repeat the question until he choose one of them
read -e -p $'Choose one of \e[33mmysql,pgsql\033[0m for your RDBMS? \n' -i "mysql" DC_RDBMS
while [ "$DC_RDBMS" != "mysql" ] && [ "$DC_RDBMS" != "pgsql" ]; do
    read -e -p $'Choose one of \e[33mmysql,pgsql\033[0m for your RDBMS? \n' -i "mysql" DC_RDBMS
done

# replace "RDBMS_SERVICE_NAME" with $DC_RDBMS in docker-compose.yml
sed -i "s|RDBMS_SERVICE_NAME|$DC_RDBMS|g" docker-compose.yml

# set RDBMS to ./src/.env file
sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=$DC_RDBMS|g" ./src/.env

# remove the other service from docker-compose.yml file
if [ "$DC_RDBMS" == "mysql" ]; then
    # clear all lines between "##-- PGSQL BOF --##" and "##-- PGSQL EOF --##" in docker-compose.yml file
    sed -i '/^##-- PGSQL BOF --##$/,/##-- PGSQL EOF --##/d' docker-compose.yml
    # remove all lines starting with "PGSQL_DB_" in ./src/.env file
    sed -i "s|PGSQL_DB_HOST=.*|PGSQL_DB_HOST=|g" ./src/.env
    # remove "## PostgreSQL Configurations" line in .env file
    sed -i '/## PostgreSQL Configurations/d' .env
    # remove all lines starting with "DC_PGSQL_DB_" in .env file
    sed -i '/DC_PGSQL_DB_*/d' .env
fi

if [ "$DC_RDBMS" == "pgsql" ]; then
    # clear all lines between "##-- MYSQL BOF --##" and "##-- MYSQL EOF --##" in docker-compose.yml file
    sed -i '/^##-- MYSQL BOF --##$/,/##-- MYSQL EOF --##/d' docker-compose.yml
    # remove all lines starting with "MYSQL_DB_" in ./src/.env file
    sed -i "s|MYSQL_DB_HOST=.*|MYSQL_DB_HOST=|g" ./src/.env
    # remove "## MySQL Configurations" line in .env file
    sed -i '/## MySQL Configurations/d' .env
    # remove all lines starting with "DC_MYSQL_DB_" in .env file
    sed -i '/DC_MYSQL_DB_*/d' .env
fi

# ask if user wants mongo service in stack
read -e -p $'Do you want to use \e[33mmongo\033[0m in stack? (y/n):\n' -i "y" DC_USE_MONGO
if [ "$DC_USE_MONGO" != "y" ]; then
    # clear all lines between "##-- MONGO BOF --##" and "##-- MONGO EOF --##" in docker-compose.yml file
    sed -i '/^##-- MONGO BOF --##$/,/##-- MONGO EOF --##/d' docker-compose.yml
    # remove all lines starting with "MONGO_DB_" in ./src/.env file
    sed -i "s|MONGO_DB_HOST=.*|MONGO_DB_HOST=|g" ./src/.env
    # remove "## MongoDB Configurations" line in .env file
    sed -i '/## MongoDB Configurations/d' .env
    # remove all lines starting with "DC_MONGO_DB_" in .env file
    sed -i '/DC_MONGO_DB_*/d' .env
fi

clear
echo -e "\e[32mDone! Your stack is ready!\033[0m\nNow you can run \e[33mbash 2-up-run-stack.sh \033[0m to build and start your stack.\n"

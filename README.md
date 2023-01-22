# dc-larastack v2 Starter-Kit
[![Build Status](https://files.ariadata.co/file/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/dc-larastack-v2.svg)
![](https://img.shields.io/github/watchers/ariadata/dc-larastack-v2.svg)
![](https://img.shields.io/github/forks/ariadata/dc-larastack-v2.svg)

### Laravel Stack for local and production , includes:
* workspace based on [s6-overlay](https://github.com/just-containers/s6-overlay)
  * nginx
  * php-fpm
* supervisor (schedule , queue ,short-schedule , horizon , ...)
* MariaDb
* PHPMyAdmin
* PostgreSQL
* MongoDb
* Redis
* npm
* zabbix-agent
* fresh [laravel 9.x](https://laravel.com/docs/9.x) from these laravel repos ( [basic](https://github.com/ariadata/dc-larastack-v2-laravel-basic) or [jetstream](https://github.com/ariadata/dc-larastack-v2-laravel-jetstream) ) that configured for this stack.

### This needs :

* 🧪 for **Local** : dockerhost : install from [link-1](https://github.com/ariadata/dockerhost-sh) or [link-2](https://github.com/ariadata/ubuntu-sh)

* 🌐 for **Production** : [dockerhost](https://github.com/ariadata/dockerhost-sh) + [Nginx-Proxy-Manager](https://github.com/ariadata/dc-nginxproxymanager)

---
# ✅ Usage : 
### 1️⃣ Install and initialize
```bash
git clone https://github.com/ariadata/dc-larastack-v2.git dc-larastack && cd dc-larastack
bash init.sh
```
### 2️⃣ Config bash_liases
Copy these lines into `.bash_aliases` of your system :
```bash
alias larastack='docker-compose exec -u webuser workspace'
alias larastack-supervisor='docker-compose exec -u webuser supervisor supervisorctl'
alias lpa='larastack php artisan'
```
### 3️⃣ Prepare and run
```bash
docker-compose up -d
docker-compose exec -u webuser workspace composer update
docker-compose exec -u webuser workspace php artisan key:generate
docker-compose exec -u webuser workspace php artisan migrate:fresh --force

docker-compose exec -u webuser workspace ./vendor/bin/pint

docker-compose exec -u webuser workspace npm install
docker-compose exec -u webuser workspace npm run build

docker-compose exec -u webuser workspace ./vendor/bin/pest
docker-compose exec -u webuser supervisor supervisorctl restart laravel-schedule laravel-short-schedule
```
### ☑️ Usage Commands
##### Commands :
```bash
larastack composer update
larastack composer php artisan key:generate
larastack composer php artisan migrate:fresh --force
larastack composer ./vendor/bin/pint
larastack-supervisor restart all

# php artisan test
larastack php artisan test

# composer install XXX
larastack composer require XXX

# restart short-schedule and shcedule
larastack-supervisor restart laravel-schedule laravel-short-schedule

# pint/clean code
larastack ./vendor/bin/pint

# system down/up
docker-compose down
docker-compose up -d

# npm build commands :
larastack npm install
larastack npm run build

```
##### 📘 Other commands :

---
## 🔗 Other Links
* [sample](https://sample.com) #description

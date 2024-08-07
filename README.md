# Laravel docker-compose stack v2
[![Build Status](https://raw.githubusercontent.com/ariadata/ariadata-files/main/public-assets/images/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/dc-larastack-v2.svg)
![](https://img.shields.io/github/watchers/ariadata/dc-larastack-v2.svg)
![](https://img.shields.io/github/forks/ariadata/dc-larastack-v2.svg)

### Laravel Stack for local and production (customizable) , includes:
* workspace based on [s6-overlay](https://github.com/just-containers/s6-overlay)
  * nginx
  * php-fpm (available versions are 7.4 ,8.0 ,8.1 ,8.2)
* supervisor ([schedule](https://laravel.com/docs/9.x/scheduling) , [queue](https://laravel.com/docs/9.x/queues) ,[short-schedule](https://github.com/spatie/laravel-short-schedule) , [horizon](https://laravel.com/docs/9.x/horizon) , ...)
* MariaDb
* PostgreSQL
* MongoDb
* Redis
* [Adminer](https://hub.docker.com/_/adminer/) full
* npm included
* fresh custom [laravel 10.x](https://laravel.com/docs/9.x) from [this repo](https://github.com/ariadata/dc-larastack-v2-laravel-basic) that customized for this stack.

### This needs `dockerhost` , install from [here](https://github.com/ariadata/dockerhost-sh)

---
# ✅ Usage :
### 1️⃣ Config bash_aliases
Copy these lines into `.bash_aliases` or `.bashrc` of your system :
```bash
alias larastack='docker-compose exec -u webuser workspace'
alias larastack-supervisor='docker-compose exec -u webuser supervisor supervisorctl'
alias lpa='larastack php artisan'
function lpa() {
    echo "Running lpa command: $@"
    larastack php artisan $@
}
```
### 2️⃣ Initialize
```bash
git clone https://github.com/ariadata/dc-larastack-v2.git dc-larastack && cd dc-larastack

# make certs
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout ./configs/nginx/ssl/default.key -out ./configs/nginx/ssl/default.crt

bash 1-init.sh
```

### 3️⃣ Prepare and run
```bash
bash 2-up-run-stack.sh
```
### ☑️ Usage Commands
##### Example commands :
```bash
larastack composer update
larastack composer require XXX

# laravel artisan commands
# lpa = larastack php artisan
lpa make:controller ExampleController
lpa key:generate
lpa migrate:fresh --force
lpa make:migration create_example_table

# supervisor commands
larastack-supervisor restart all
larastack-supervisor status all
larastack-supervisor restart laravel-schedule laravel-short-schedule horizon:

# pint/clean code
larastack ./vendor/bin/pint

# Run Tests :
larastack ./vendor/bin/pest

# system down/up
docker-compose down
docker-compose up -d

# npm build commands :
larastack npm install
larastack npm run build

```
for `mongodb` check [here](https://www.mongodb.com/compatibility/mongodb-laravel-integration)
---
# 📝 Notes :
* `larastack` is alias for `docker-compose exec -u webuser workspace`
* `larastack-supervisor` is alias for `docker-compose exec -u webuser supervisor supervisorctl`
* `lpa` is alias for `larastack php artisan`

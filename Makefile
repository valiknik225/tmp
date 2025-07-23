.PHONY: up up-d up-b up-r down composer composer-install composer-update run cache-clear setup

setup:
	@test -f .env.local || cp .env.local.dist .env.local
	@test -f MakefileCustom || cp MakefileCustom.dist MakefileCustom
	@rm -rf MakefileInstall
	@docker network ls | grep tm || docker network create tm

-include .env.local

# Змінні для Docker
PROJECT_NAME ?= $(shell grep -m 1 'PROJECT_NAME' .env.local | cut -d '=' -f2-)

DOCKER_COMPOSE = docker-compose --env-file .env.local
PHP_BASH = docker exec -it php_$(PROJECT_NAME) /bin/bash
DOCKER_EXEC = $(PHP_BASH) -c

symfony-i: install-init

# Docker Compose Commands
up: setup
	$(DOCKER_COMPOSE) up

up-d: setup
	$(DOCKER_COMPOSE) up -d

up-b: setup
	$(DOCKER_COMPOSE) up --build

up-r: setup
	$(DOCKER_COMPOSE) up --force-recreate

down: setup
	$(DOCKER_COMPOSE) down --remove-orphans

exec: setup
	$(DOCKER_EXEC) "echo -e '\033[32m'; /bin/bash"

# Composer Commands
composer: setup
	$(DOCKER_EXEC) "composer $(CMD)"

composer-install: CMD = install
composer-install: composer

composer-update: CMD = update
composer-update: composer

composer-i: composer-install
composer-u: composer-update

# Application Specific Commands
console: setup
	$(DOCKER_EXEC) "php bin/console $(EXEC)"

symfony: console

cache-clear: EXEC = cache:clear --env=dev \
	&& php bin/console cache:pool:clear cache.global_clearer --env=dev
cache-clear: symfony

cache-clear-prod: EXEC = cache:clear --env=prod \
	&& php bin/console cache:pool:clear cache.global_clearer --env=prod
cache-clear-prod: symfony

cache-clear-test: EXEC = cache:clear --env=test
cache-clear-test: symfony

fixtures-load: EXEC = doctrine:fixtures:load
fixtures-load: symfony

migrations-diff: EXEC = doctrine:migrations:diff
migrations-diff: symfony

migrations-migrate: EXEC = doctrine:migrations:migrate
migrations-migrate: symfony

migrations-migrate-n: EXEC = doctrine:migrations:migrate -n
migrations-migrate-n: symfony

run: EXEC = "$(filter-out $@,$(MAKECMDGOALS))"
run:
	@if [ -z "$(EXEC)" ]; then \
		echo "Error: No arguments provided for 'run' command."; \
		exit 1; \
	fi
	$(DOCKER_EXEC) "php bin/console $(EXEC)"

# Це скидає будь-які аргументи передані до 'run', роблячи їх не-цілями
%:
	@:

GREEN=\033[0;32m
BLUE=\033[0;34m
YELLOW=\033[1;33m
PURPLE=\033[0;35m
NC=\033[0m

-include MakefileCustom
-include MakefileInstall

MakefileInstall:
	@:

COMPOSER := ./composer.phar
PHPUNIT  := ./phpunit.phar

DOCKER_REGISTRY_ID     := 675359748603
# https://github.com/docker/compose/releases
DOCKER_COMPOSE_VERSION := 1.16.1
DOCKER_COMPOSE         := ./docker-compose

AWS_REGION  := us-west-2
AWS_PROFILE := phpcon2017

.DEFAULT_GOAL := help
.PHONY: help deps clean build pull push run stop docker_login ecs_deploy

# https://news.ycombinator.com/item?id=11195539
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-28s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

deps: $(COMPOSER) $(DOCKER_COMPOSE) docker_login composer_install ## Install dependencies

clean: $(DOCKER_COMPOSE)
	$(DOCKER_COMPOSE) down

build: $(DOCKER_COMPOSE) docker_login pull ## Build container(s)
	$(DOCKER_COMPOSE) up -d --force-recreate --build --remove-orphans \
	|| ($(DOCKER_COMPOSE) rm --force && exit 1)
	@echo "==> Checking path of / like as smoke testing" && sleep 5; # awaiting launched
	curl -f -D - "http://127.0.0.1/hello" -v
	$(DOCKER_COMPOSE) rm --stop --force

pull: $(DOCKER_COMPOSE) docker_login ## Pull docker image(s) to Amazon ECR Repository
	$(DOCKER_COMPOSE) $@ --parallel --ignore-pull-failures

push: $(DOCKER_COMPOSE) docker_login ## Push docker image(s) to Amazon ECR Repository
	$(DOCKER_COMPOSE) $@

deploy: ## Deploy (rolling-update) to production
	@$(MAKE) ecs_deploy

canary_deploy: ## Deploy (rolling-update) to canary environment
	@$(MAKE) ecs_deploy ecs_service=phpcon2017-canary

ecs_deploy: ecs_cluster = phpcon2017
ecs_deploy: ecs_service = phpcon2017
ecs_deploy:
	docker run --rm -it \
	  -v ~/.aws:/root/.aws:ro \
	  -e AWS_DEFAULT_REGION=$(AWS_REGION) \
	  -e AWS_PROFILE=$(AWS_PROFILE) \
	  nishigori/ecs-deploy:1.3.1 $(ecs_cluster) $(ecs_service)


docker_login: ~/.aws/credentials ## Logged-in docker registory (amazon ecr)
	$$(aws ecr get-login --no-include-email --registry-ids $(DOCKER_REGISTRY_ID))

test: $(PHPUNIT) ## Run the test suite
	docker run --rm -it -v $$(pwd):/app -w /app php:7-alpine $(PHPUNIT)

run: $(DOCKER_COMPOSE) ## [dev] Run container(s)
	-$(DOCKER_COMPOSE) up --abort-on-container-exit --force-recreate

stop: $(DOCKER_COMPOSE) ## [dev] Stop container(s)
	$(DOCKER_COMPOSE) $@

composer_%: $(DOCKER_COMPOSER) ## [dev] Exec composer.phar (install, update, ...)
	docker run --rm -it -v $$(pwd):/app -w /app php:7-alpine $(COMPOSER) $* -vvv

$(PHPUNIT):
	curl -SsL -o $@ https://phar.phpunit.de/phpunit-5.7.phar
	@chmod +x $@
	$@ --version

$(COMPOSER):
	curl -SsL -o $@ https://getcomposer.org/composer.phar
	@chmod +x $@
	$@ --version

$(DOCKER_COMPOSE): os_type = $(shell echo $(shell uname) | tr A-Z a-z)
$(DOCKER_COMPOSE):
	curl -L -o $@ https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-$(os_type)-$$(uname -m)
	@chmod +x $@

~/.aws/credentials:
	@test -f $@ || (echo 'ERROR: Not found $@ needs your settings like `aws configure`' && exit 1)

tailf_ecs_logs_php: ## [operation] Watch to logs of php containers
	@$(MAKE) __watch_cloudwatch_log_stream__ LOG_GROUP=phpcon2017/php

tailf_ecs_logs_nginx: ## [operation] Watch to logs of nginx containers
	@$(MAKE) __watch_cloudwatch_log_stream__ LOG_GROUP=phpcon2017/nginx

tailf_ecs_logs_php_canary: ## [operation] Watch to logs of php containers that is canary
	@$(MAKE) __watch_cloudwatch_log_stream__ LOG_GROUP=phpcon2017-canary/php

tailf_ecs_logs_nginx_canary: ## [operation] Watch to logs of nginx containers that is canary
	@$(MAKE) __watch_cloudwatch_log_stream__ LOG_GROUP=phpcon2017-canary/nginx

tailf_ecs_agent_logs: ## [operation] Watch to logs of ecs cluster as docker hosts
	@$(MAKE) __watch_cloudwatch_log_stream__ LOG_GROUP=phpcon2017/ecs-agent

__watch_cloudwatch_log_stream__: LOG_GROUP = phpcon2017/php
__watch_cloudwatch_log_stream__:
	docker run --rm -it \
	  -v ~/.aws:/root/.aws:ro \
	  -e AWS_DEFAULT_REGION=$(AWS_REGION) \
	  -e AWS_PROFILE=$(AWS_PROFILE) \
	  nishigori/awslogs get $(LOG_GROUP) -w --no-group --no-stream

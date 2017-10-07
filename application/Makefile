COMPOSER := ./composer.phar
PHPUNIT  := ./phpunit.phar

DOCKER_REGISTRY_ID     := 675359748603
# https://github.com/docker/compose/releases
DOCKER_COMPOSE_VERSION := 1.16.1
DOCKER_COMPOSE         := ./docker-compose

.DEFAULT_GOAL := help
.PHONY: help deps clean build pull push run stop docker_login

# https://news.ycombinator.com/item?id=11195539
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-32s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

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

canary:

run: $(DOCKER_COMPOSE) ## [dev] Run container(s)
	-$(DOCKER_COMPOSE) up --abort-on-container-exit --force-recreate

stop: $(DOCKER_COMPOSE) ## [dev] Stop container(s)
	$(DOCKER_COMPOSE) $@

test: $(PHPUNIT) ## Run the test suite
	docker run --rm -it -v $$(pwd):/app -w /app php:7-alpine $(PHPUNIT)

composer_%: $(DOCKER_COMPOSER) ## Exec composer.phar (%: install, update, ...)
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

docker_login: ~/.aws/credentials ## Logged-in docker registory (amazon ecr)
	$$(aws ecr get-login --no-include-email --registry-ids $(DOCKER_REGISTRY_ID))

~/.aws/credentials:
	@test -f $@ || (echo 'ERROR: Not found $@ needs your settings like `aws configure`' && exit 1)

COMPOSER := ./composer.phar

.DEFAULT_GOAL := help
.PHONY: help

# https://news.ycombinator.com/item?id=11195539
help:
	@awk -F ':|##' '/^[^\t].+?:.*?##/ { printf "\033[36m%-32s\033[0m %s\n", $$1, $$NF }' $(MAKEFILE_LIST)

$(COMPOSER):
	curl -SsL -o $@ https://getcomposer.org/composer.phar
	@chmod +x $@
	$@ --version

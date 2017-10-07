TERRAFORM              := ./terraform
# https://github.com/hashicorp/terraform/blob/v0.10.7/CHANGELOG.md
TERRAFORM_VERSION      := 0.10.7
TERRAFORM_STATE        := ./terraform.tfstate

.DEFAULT_GOAL := default
.PHONY: default apply init test $(TERRAFORM)

default: init plan

all: init apply test

init: ~/.aws/credentials .ssh/aws-keypair $(TERRAFORM)
	$(TERRAFORM) init -get-plugins=true -get=true

plan: init
	$(TERRAFORM) $@ -state=$(TERRAFORM_STATE)

apply: init
	$(TERRAFORM) $@ -state=$(TERRAFORM_STATE) -auto-approve=false

test: ## Run tests
	docker pull nishigori/awspec
	docker run --rm \
	  -v ~/.aws:/root/.aws:ro \
	  -v $(CURDIR)/spec:/awspec:ro \
	  nishigori/awspec

.ssh/aws-keypair:
	@mkdir $(@D)
	ssh-keygen -t rsa -b 4096 -N '' -f $@

~/.aws/credentials:
	@test -f $@ || (echo 'ERROR: Not found $@ needs your settings like `aws configure`' && exit 1)

$(TERRAFORM): os_type      = $(shell echo $(shell uname) | tr A-Z a-z)
$(TERRAFORM): archive      = terraform_$(TERRAFORM_VERSION)_$(os_type)_amd64.zip
$(TERRAFORM): download_url = https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/$(archive)
$(TERRAFORM):
	@if [ -f $(TERRAFORM) ]; then $(TERRAFORM) -v | head -n1 | grep -q '$(TERRAFORM_VERSION)$$' || rm -f $(TERRAFORM); fi
	@if [ ! -f $(TERRAFORM) ]; then \
	  echo "Installing Terraform ..." && curl -L -fsS --retry 2 -o $(archive) $(download_url); \
	  unzip $(archive) 1> /dev/null && rm -f $(archive); \
	fi
	@$(TERRAFORM) version

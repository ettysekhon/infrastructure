.PHONY: all init fmt validate test clean help

all: fmt validate test

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	terraform init

fmt: ## Format Terraform code
	terraform fmt -recursive

validate: init ## Validate Terraform configuration
	terraform validate

test: init ## Run unit tests
	terraform test

clean: ## Clean up Terraform files
	rm -rf .terraform .terraform.lock.hcl

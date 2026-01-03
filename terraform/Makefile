.PHONY: help validate apply format clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

validate: ## Validate all stacks (plan only)
	./validate.sh

apply: ## Apply all stacks in DAG order
	./validate.sh --apply

format: ## Format all terraform files
	terraform fmt -recursive -diff
	@echo "Formatting complete"

clean: ## Remove .terraform directories from all stacks
	rm -rf config/.terraform config/.terraform.lock.hcl
	rm -rf bootstrap/.terraform bootstrap/.terraform.lock.hcl
	rm -rf identity/.terraform identity/.terraform.lock.hcl
	rm -rf cluster/.terraform cluster/.terraform.lock.hcl
	rm -rf artifact-registry/.terraform artifact-registry/.terraform.lock.hcl
	rm -rf namespaces/.terraform namespaces/.terraform.lock.hcl


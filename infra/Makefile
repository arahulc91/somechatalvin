.PHONY: help init plan apply destroy output logs build

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

init: ## Initialize Terraform
	terraform init

plan: ## Show Terraform plan
	terraform plan

apply: ## Apply Terraform configuration
	terraform apply

destroy: ## Destroy infrastructure
	terraform destroy

output: ## Show Terraform outputs
	terraform output

output-url: ## Show LibreChat URL
	@terraform output -raw librechat_url

build: ## Build and push Docker image to ACR
	./build.sh

logs: ## Tail LibreChat logs
	@RESOURCE_GROUP=$$(terraform output -raw resource_group_name) && \
	APP_NAME=$$(az containerapp list -g $$RESOURCE_GROUP --query "[?contains(name, 'librechat-app')].name" -o tsv) && \
	az containerapp logs show --name $$APP_NAME --resource-group $$RESOURCE_GROUP --follow

status: ## Check deployment status
	@RESOURCE_GROUP=$$(terraform output -raw resource_group_name) && \
	az containerapp list -g $$RESOURCE_GROUP --query "[].{Name:name, Status:properties.runningStatus}" -o table

restart: ## Restart LibreChat container
	@RESOURCE_GROUP=$$(terraform output -raw resource_group_name) && \
	APP_NAME=$$(az containerapp list -g $$RESOURCE_GROUP --query "[?contains(name, 'librechat-app')].name" -o tsv) && \
	az containerapp revision restart --name $$APP_NAME --resource-group $$RESOURCE_GROUP

open: ## Open LibreChat in browser
	@open $$(terraform output -raw librechat_url) || xdg-open $$(terraform output -raw librechat_url)


############
# POLICIES #
############

.PHONY: render-policies
render-policies: ## Render policies
	@rm -rf ./content/en/policies/*
	@cd render && go run . -- https://github.com/kyverno/policies/main ../content/en/policies/

########
# HELP #
########

.PHONY: help
help: ## Shows the available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

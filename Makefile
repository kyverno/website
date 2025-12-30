
###########
# CODEGEN #
###########

.PHONY: codegen-cli-docs
codegen-cli-docs: ## Build CLI docs
	@rm -rf ./content/en/docs/kyverno-cli/reference/kyverno*.md
	@docker run --user root -v ${PWD}:/work --rm ghcr.io/kyverno/kyverno-cli docs	\
		--autogenTag=false															\
		--website																	\
		--noDate																	\
		--markdownLinks																\
		--output "/work/content/en/docs/kyverno-cli/reference"

.PHONY: codegen-policies
codegen-policies: ## Render policies
	@rm -rf ./content/en/policies/*/
	@cd render && go run . -- https://github.com/kyverno/policies/main ../content/en/policies/

.PHONY: codegen
codegen: ## Rebuild all generated code and docs
codegen: codegen-policies
codegen: codegen-cli-docs

.PHONY: verify-codegen
verify-codegen: ## Verify all generated code and docs are up to date
verify-codegen: codegen
	@echo Checking codegen is up to date... >&2
	@git --no-pager diff -- .
	@echo 'If this test fails, it is because the git diff is non-empty after running "make codegen".' >&2
	@echo 'To correct this, locally run "make codegen", commit the changes, and re-run tests.' >&2
	@git diff --quiet --exit-code -- .

########
# HUGO #
########

.PHONY: build
build: ## Build the Hugo site
	@hugo build

.PHONY: serve
serve: ## Run the Hugo development server
	@hugo server

.PHONY: clean
clean: ## Clean generated files
	@rm -rf public/

###########
# LINK CHECK #
###########

.PHONY: check-links
check-links: build ## Check links in the built Hugo site using lychee
	@lychee --config config/lychee.toml --max-concurrency 2 --max-retries 5 --retry-wait-time 10 --accept 200,429 --timeout 60 -E --root-dir "${PWD}/public" public

########
# HELP #
########

.PHONY: help
help: ## Shows the available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

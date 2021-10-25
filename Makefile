HUGO_VERSION      = $(shell grep ^HUGO_VERSION netlify.toml | tail -n 1 | cut -d '=' -f 2 | tr -d " \"\n")
NODE_BIN          = node_modules/.bin
NETLIFY_FUNC      = $(NODE_BIN)/netlify-lambda

# The CONTAINER_ENGINE variable is used for specifying the container engine. By default 'docker' is used
# but this can be overridden when calling make, e.g.
# CONTAINER_ENGINE=podman make container-image
CONTAINER_ENGINE ?= docker
IMAGE_VERSION=$(shell scripts/hash-files.sh Dockerfile Makefile | cut -c 1-12)
CONTAINER_IMAGE   = kyverno-hugo:v$(HUGO_VERSION)-$(IMAGE_VERSION)
CONTAINER_RUN     = $(CONTAINER_ENGINE) run --rm --interactive --tty --volume $(CURDIR):/src

CCRED=\033[0;31m
CCEND=\033[0m

.PHONY: all build build-preview help serve

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

npm-dependencies-install: ## Install the required npm dependencies backing the website, only if they haven't been installed yet
	@if [ ! -d "node_modules" ]; then npm install; else echo "npm dependencies already found to be installed. To re-install, run make npm-dependencies-force-install"; fi

npm-dependencies-purge: ## Purge all the npm dependencies installed under this project
	@rm -rf node_modules

npm-dependencies-force-install: ## Install the required npm dependencies backing the website even if they already were installed
	@npm install

module-check: npm-dependencies-install
	@git submodule status --recursive | awk '/^[+-]/ {printf "\033[31mWARNING\033[0m Submodule not initialized: \033[34m%s\033[0m\n",$$2}' 1>&2

all: build ## Build site with production settings and put deliverables in ./public

build: module-check ## Build site with production settings and put deliverables in ./public
	hugo --minify

build-preview: module-check ## Build site with drafts and future posts enabled
	hugo --buildDrafts --buildFuture

deploy-preview: ## Deploy preview site via netlify
	hugo --enableGitInfo --buildFuture -b $(DEPLOY_PRIME_URL)

functions-build:
	$(NETLIFY_FUNC) build functions-src

check-headers-file:
	scripts/check-headers-file.sh

production-build: build check-headers-file ## Build the production site and ensure that noindex headers aren't added

non-production-build: ## Build the non-production site, which adds noindex headers to prevent indexing
	hugo --enableGitInfo

serve: module-check ## Boot the development server.
	hugo server --buildFuture --watch=false

container-image: ## Create a container image with tooling to build/serve the website locally
	$(CONTAINER_ENGINE) build . \
		--network=host \
		--tag $(CONTAINER_IMAGE) \
		--build-arg HUGO_VERSION=$(HUGO_VERSION)

container-build: module-check ## Build the website locally using a container
	$(CONTAINER_RUN) $(CONTAINER_IMAGE) hugo --minify

container-serve: module-check ## Serve the website locally, from a container
	$(CONTAINER_RUN) --mount type=tmpfs,destination=/src/resources,tmpfs-mode=0777 -p 1313:1313 $(CONTAINER_IMAGE) hugo server --buildFuture --bind 0.0.0.0

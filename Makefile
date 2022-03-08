#!make
-include .env

HUB ?= b0rr3g0
IMAGE ?= service-mesh-wasm-go
VERSION ?= 0.1
MAIN ?= main.go
CONTAINER ?= container/Dockerfile
.DEFAULT_GOAL := help

.PHONY: help 
help: ## Show opstions and short description
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build 
build: ## Build the golang application and generate .wasm module
	@find ./src -type f -name ${MAIN} | xargs -Ip tinygo build -o src/extension.wasm -scheduler=none p

.PHONY: container
image: clean build ## Clean, build and generate the container image with the wasm module
	@mkdir .build.tmp
	@cp src/extension.wasm .build.tmp/
	@cp container/manifest.yaml .build.tmp/
	@cd .build.tmp/
	@podman build -t ${HUB}/${IMAGE}:${VERSION} . -f ${CONTAINER}

.PHONY: container 
image-push: image ## Clean, build, generate the image and upload it
	podman push ${HUB}/${IMAGE}:${VERSION}

.PHONY: clean
clean: # Remove temporal files and .wasm module
	@rm -rf .build.tmp
	@find ./src -type f -name *wasm | xargs rm -f

.PHONY: install
install: ## Install golang requires modules
	@go mod edit -require=github.com/tetratelabs/proxy-wasm-go-sdk@main
	@go mod download github.com/tetratelabs/proxy-wasm-go-sdk

.PHONY: init
init: ## Init the golang module the first time
	@go mod init ${IMAGE}
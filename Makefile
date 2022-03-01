HUB ?= b0rr3g0
IMAGE ?= service-mesh-wasm-go
VERSION ?= 0.1-SNAPSHOT
MAIN ?= main.go
CONTAINER ?= container/Dockerfile

.PHONY: build
build: 
	@find ./src -type f -name ${MAIN} | xargs -Ip tinygo build -o p.wasm -scheduler=none -target=wasi p

.PHONY: container
image: clean build
	mkdir .build.tmp
	cp src/main.go.wasm .build.tmp/
	cp container/manifest.yaml .build.tmp/
	cd .build.tmp/
	podman build -t ${HUB}/${IMAGE}:${VERSION} . -f ${CONTAINER}

.PHONY: clean
clean: 
	rm -rf .build.tmp

.PHONY: install
install: 
	go mod edit -require=github.com/tetratelabs/proxy-wasm-go-sdk@main
	go mod download github.com/tetratelabs/proxy-wasm-go-sdk

.PHONY: init
init: 
	go mod init ${IMAGE}
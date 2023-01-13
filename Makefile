# Usage:
# make        # compile all binary
# make clean  # remove ALL binaries and objects

NAME                       := dnscrypt-proxy
CC                         := gcc                            # compiler to use
DOCKER_VERSION             := $(shell docker --version)

# DOCKER_REGISTRY            ?= quay.io
IMAGE_NAME                 := dnscrypt-proxy
IMAGE_PREFIX               ?= issenn
IMAGE_TAG                  ?= latest

ifdef DOCKER_REGISTRY
    REPOSITORY             := $(DOCKER_REGISTRY)/$(IMAGE_PREFIX)/$(IMAGE_NAME)
else
    REPOSITORY             := $(IMAGE_PREFIX)/$(IMAGE_NAME)
endif

DNSCRYPT_PROXY_VERSION     ?= 2.1.2
# https://docs.brew.sh/Cask-Cookbook
# DNSCRYPT_PROXY_VERSION_MAJOR         := $(shell echo $(DNSCRYPT_PROXY_VERSION) | sed "s/^\([0-9]*\).*/\1/")
DNSCRYPT_PROXY_VERSION_MAJOR         := $(shell echo $(DNSCRYPT_PROXY_VERSION) | cut -f1 -d.)
# DNSCRYPT_PROXY_VERSION_MINOR         := $(shell echo $(DNSCRYPT_PROXY_VERSION) | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
DNSCRYPT_PROXY_VERSION_MINOR         := $(shell echo $(DNSCRYPT_PROXY_VERSION) | cut -f2 -d.)
# DNSCRYPT_PROXY_VERSION_PATCH         := $(shell echo $(DNSCRYPT_PROXY_VERSION) | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")
DNSCRYPT_PROXY_VERSION_PATCH         := $(shell echo $(DNSCRYPT_PROXY_VERSION) | cut -f3 -d.)
DNSCRYPT_PROXY_VERSION_MAJOR_MINOR   := $(DNSCRYPT_PROXY_VERSION_MAJOR).$(DNSCRYPT_PROXY_VERSION_MINOR)

COMMIT                     := $(shell git rev-parse HEAD)

LABEL                      ?= "Maintainer=Issenn <issenn@issenn.ml>"
PUSH_IMAGE                 ?= false
LATEST                     := latest

PROXY                      ?= socks5://10.0.0.131:10810
NO_PROXY                   ?= localhost,127.0.0.1
USE_PROXY                  ?= false

DOCKER_BUILDKIT            ?= false

default: all
	@echo 'Run `make options` for a list of all options'

options: help
	@echo
	@echo 'Options:'
	@echo 'DOCKER = $(DOCKER_VERSION)'
	# @echo 'DOCDIR = $(DOCDIR)'
	# @echo 'DESTDIR = $(DESTDIR)'

help:
	@echo 'make:                 Test and compile.'
	@echo 'make clean:           Remove the compiled files'

all: build

build:
    ifeq ($(USE_PROXY), true)
	    env DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) \
	        docker build -t $(REPOSITORY):$(IMAGE_TAG) \
	            -f Dockerfile \
	            --label $(LABEL) \
	            --build-arg HTTP_PROXY="$(PROXY)" \
	            --build-arg HTTPS_PROXY="$(PROXY)" \
	            --build-arg NO_PROXY="$(NO_PROXY)" \
	            --build-arg DNSCRYPT_PROXY_VERSION="$(DNSCRYPT_PROXY_VERSION)" .
	            # --build-arg BUILDPLATFORM=$(BUILDPLATFORM) \
	            # --build-arg TARGETOS=$(TARGETOS) \
	            # --build-arg TARGETARCH=$(TARGETARCH) \
    else
	    env DOCKER_BUILDKIT=$(DOCKER_BUILDKIT) \
	        docker build -t $(REPOSITORY):$(IMAGE_TAG) \
	            -f Dockerfile \
	            --label $(LABEL) \
	            --build-arg DNSCRYPT_PROXY_VERSION="$(DNSCRYPT_PROXY_VERSION)" .
    endif


test:

compile:

clean:
	@echo "Cleaning up..."

.PHONY : clean-docker-cache
clean-docker-cache :
	docker builder prune

.PHONY : default options help all build test compile clean

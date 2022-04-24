SHELL := /bin/bash

GCC_VERSION := 11
DEBIAN_VERSION := bullseye
CMAKE_VERSION := 3.20.5

NAMESPACE := invasy
IMAGE := gcc-remote
CONTAINER := gcc_remote
PORT := 22002

image_name := $(NAMESPACE)/$(IMAGE)
image_version := $(GCC_VERSION)-cmake-$(CMAKE_VERSION)
tag := $(image_name):$(image_version)
latest := $(image_name):latest

.PHONY: all build run login push pull up down list clean
all: build

build: Dockerfile
	@docker build $(if $(no_cache),--no-cache )\
		--build-arg=GCC_VERSION=$(GCC_VERSION) \
		--build-arg=DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--build-arg=CMAKE_VERSION=$(CMAKE_VERSION) \
		--tag "$(tag)" --tag "$(latest)" .

run: build
	@docker run --detach --cap-add=sys_admin --name="$(CONTAINER)" \
		--publish="127.0.0.1:$(PORT):22" --restart=unless-stopped "$(latest)"

login:
	@$(if $(DOCKER_USERNAME),,$(error DOCKER_USERNAME is undefined))\
	$(if $(DOCKER_PASSWORD),,$(error DOCKER_PASSWORD is undefined))\
	echo "$(DOCKER_PASSWORD)" | docker login --username="$(DOCKER_USERNAME)" --password-stdin "$(DOCKER_REGISTRY)"

push: build login
	@docker image push "$(tag)" && \
	docker image push "$(latest)"

pull:
	@docker image pull "$(latest)"

up: docker-compose.yml
	@docker-compose up -d

down: docker-compose.yml
	@docker-compose down

shell:
	@docker exec --interactive --tty --user builder --workdir /home/builder $(CONTAINER) /bin/bash

root:
	@docker exec --interactive --tty --workdir /root $(CONTAINER) /bin/bash

list:
	@-docker container ls -f name=$(CONTAINER)
	@-docker image ls $(image_name)

clean:
	@-docker container rm $$(docker container ls -q -f name=$(CONTAINER))
	@-docker image rm $$(docker image ls -q $(image_name))

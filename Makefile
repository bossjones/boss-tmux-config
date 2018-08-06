.PHONY: add-new-repository all bootstrap-runtime-system bootstrap-runtime-user build build-commit build-force build-local build-push build-push-local build-push-two-phase build-push-two-phase-force build-two-phase build-two-phase-force check-app-installed delet-remotes delete-remotes docker-shell full-setup-base install-flatpak-system-deps install-gnome-2.6-runtime install-gpg-keys install-runtime install-runtime-system install-runtime-user install-the-app list push push-force push-local rebuild-base remote-add remote-add-system remote-add-user run-app run-build run-flatpak-builder-base-bash run-flatpak-builder-debug-base run-flatpak-builder-uninstall-base run-flatpak-debug-base step1 step2 step3 step4 step5 tag tag-local travis

SHELL := $(shell which bash)

DIR   := $(shell basename $$PWD)

RED=\033[0;31m
GREEN=\033[0;32m
ORNG=\033[38;5;214m
BLUE=\033[38;5;81m
NC=\033[0m

export RED
export GREEN
export NC
export ORNG
export BLUE

export PATH := ./bin:./venv/bin:$(PATH)

github_org := bossjones
github_repo_name := boss-tmux-config
docker_developer_chroot := .docker-developer

GIT_BRANCH    = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA       = $(shell git rev-parse HEAD)
BUILD_DATE    = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VERSION       = latest
NON_ROOT_USER = developer


IMAGE_TAG           := $(github_org)/$(github_repo_name):$(GIT_SHA)
IMAGE_TAG_TEST      := $(github_org)/$(github_repo_name)-test:$(GIT_SHA)
CONTAINER_NAME      := $(shell echo -n $(IMAGE_TAG) | openssl dgst -sha1 | sed 's/^.* //'  )
CONTAINER_NAME_TEST := $(shell echo -n $(github_org)/$(github_repo_name)-test:$(GIT_SHA) | openssl dgst -sha1 | sed 's/^.* //'  )
FIXUID              := $(shell id -u)
FIXGID              := $(shell id -g)

LOCAL_REPOSITORY = $(HOST_IP):5000

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

# verify that certain variables have been defined off the bat
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))

list_allowed_args := interface

info:
	echo -e "$(github_org)/$(github_repo_name):$(GIT_SHA)\n"

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

# Commit backend Container
build-commit:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	time docker commit --message "Makefile docker CI dep install for $(github_org)/$(github_repo_name)" $(CONTAINER_NAME) $(IMAGE_TAG)

build:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker build --tag $(github_org)/$(github_repo_name):$(GIT_SHA) ./.ci ; \
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(github_org)/$(github_repo_name):latest
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(github_org)/$(github_repo_name):$(TAG)

build-force:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker build --rm --force-rm --pull --no-cache -t $(github_org)/$(github_repo_name):$(GIT_SHA) ./.ci ; \
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(github_org)/$(github_repo_name):latest
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(github_org)/$(github_repo_name):$(TAG)

build-local:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker build --tag $(github_org)/$(github_repo_name):$(GIT_SHA) ./.ci ; \
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(LOCAL_REPOSITORY)/$(github_org)/$(github_repo_name):latest

tag-local:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(LOCAL_REPOSITORY)/$(github_org)/$(github_repo_name):$(TAG)
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(LOCAL_REPOSITORY)/$(github_org)/$(github_repo_name):latest

push-local:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker push $(LOCAL_REPOSITORY)/$(github_org)/$(github_repo_name):$(TAG)
	docker push $(LOCAL_REPOSITORY)/$(github_org)/$(github_repo_name):latest

build-push-local: build-local tag-local push-local

tag:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(github_org)/$(github_repo_name):latest
	docker tag $(github_org)/$(github_repo_name):$(GIT_SHA) $(github_org)/$(github_repo_name):$(TAG)

build-push: build tag
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker push $(github_org)/$(github_repo_name):latest
	docker push $(github_org)/$(github_repo_name):$(GIT_SHA)
	docker push $(github_org)/$(github_repo_name):$(TAG)

push:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker push $(github_org)/$(github_repo_name):latest
	docker push $(github_org)/$(github_repo_name):$(GIT_SHA)
	docker push $(github_org)/$(github_repo_name):$(TAG)

pull:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker pull $(github_org)/$(github_repo_name):latest

push-force: build-force push

docker-shell:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker exec -ti $(github_org)/$(github_repo_name):latest /bin/bash

docker-build-test-test:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker build \
		--build-arg UID=$(FIXUID) \
		--build-arg GID=$(FIXGID) \
		-t $(github_org)/$(github_repo_name)-test:$(GIT_SHA) \
		-f .ci/Dockerfile.test \
		./.ci ; \
	docker tag $(github_org)/$(github_repo_name)-test:$(GIT_SHA) $(github_org)/$(github_repo_name)-test:latest ; \
	docker tag $(github_org)/$(github_repo_name)-test:$(GIT_SHA) $(github_org)/$(github_repo_name)-test:$(TAG)

docker-build-test-test-force:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker build \
	--build-arg UID=$(FIXUID) \
	--build-arg GID=$(FIXGID) \
	--rm --force-rm --pull --no-cache -t $(github_org)/$(github_repo_name)-test:$(GIT_SHA) -f .ci/Dockerfile.test ./.ci ; \
	docker tag $(github_org)/$(github_repo_name)-test:$(GIT_SHA) $(github_org)/$(github_repo_name)-test:latest ; \
	docker tag $(github_org)/$(github_repo_name)-test:$(GIT_SHA) $(github_org)/$(github_repo_name)-test:$(TAG)

docker-run-test-test: docker-build-test-test
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	time docker run \
	--privileged \
	-i \
	-e TRACE=1 \
	-e UID=$(FIXUID) \
	-e GID=$(FIXGID) \
	--cap-add=ALL \
	--security-opt seccomp=unconfined \
	--tmpfs /run \
	--tmpfs /run/lock \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-v $(PWD):/home/$(NON_ROOT_USER):rw \
	-d \
	--tty \
	--entrypoint "/usr/sbin/init" \
	--name $(CONTAINER_NAME_TEST) \
	$(IMAGE_TAG_TEST) true

	docker exec --tty \
	--privileged \
	-u $(NON_ROOT_USER) \
	-w /home/$(NON_ROOT_USER) \
	$(CONTAINER_NAME_TEST) env TERM=xterm bash .ci/ci-entrypoint.sh


docker-run-test-test-force: docker-build-test-test-force
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	time docker run \
	--privileged \
	-i \
	-e TRACE=1 \
	--cap-add=ALL \
	--security-opt seccomp=unconfined \
	--tmpfs /run \
	--tmpfs /run/lock \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-v $(PWD):/home/$(NON_ROOT_USER):rw \
	-d \
	--tty \
	--entrypoint "/usr/sbin/init" \
	--name $(CONTAINER_NAME_TEST) \
	$(IMAGE_TAG_TEST) true

	docker exec --tty \
	--privileged \
	-u $(NON_ROOT_USER) \
	-w /home/$(NON_ROOT_USER) \
	$(CONTAINER_NAME_TEST) env TERM=xterm bash .ci/ci-entrypoint.sh

docker-exec-test-bash:
	@printf "=======================================\n"
	@printf "\n"
	@printf "$$GREEN $@$$NC\n"
	@printf "\n"
	@printf "=======================================\n"
	docker exec -i -t \
	--privileged \
	-u $(NON_ROOT_USER) \
	-w /home/$(NON_ROOT_USER) \
	$(CONTAINER_NAME_TEST) bash -l

# FIX: placeholder
travis: pull docker-run-test-test

############################################[Docker CI - END]##################################################

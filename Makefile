# Ensure (intermediate) targets are deleted when an error occurred executing a recipe, see [1]
.DELETE_ON_ERROR:

# Enable a second expansion of the prerequisites, see [2]
.SECONDEXPANSION:

# Disable built-in implicit rules and variables, see [3, 4]
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Disable printing of directory changes, see [4]
MAKEFLAGS += --no-print-directory

# Warn about undefined variables -- useful during development of makefiles, see [4]
MAKEFLAGS += --warn-undefined-variables

# Show an auto-generated help if no target is provided, see [5]
.DEFAULT_GOAL := help

# Project root directory
export ROOT_DIR := $(abspath .)
export KUBE_APP_NAMESPACE := theklarakers
export PROJECT_NAME := theklarakers

DEPENDENCIES := \
	package-lock.json \
	package.json \
	gulpfile.js

DOCKER_IMAGE_PREFIX ?= jvisser/$(PROJECT_NAME)
DOCKER_IMAGE = $(DOCKER_IMAGE_PREFIX)-website:dist
DOCKER_BUILD_ARGS += --cache-from $(DOCKER_IMAGE)
# Prevent pulling a base image from Docker Hub that has just been built locally
DOCKER_BUILD_ARGS += $(shell echo "$?" | grep -q \.built || echo "--pull")
# Tag :dist images also with DOCKER_DEPLOY_TAG (commit hash + timestamp)
export DOCKER_DEPLOY_TAG  ?= $(shell git --no-pager show -s --format="%h")
DOCKER_DIST_IMAGE         = $(subst :dist,:$(DOCKER_DEPLOY_TAG),$(DOCKER_IMAGE))
DOCKER_BUILD_ARGS        += $(if $(findstring :dist,$(DOCKER_IMAGE)),-t $(DOCKER_DIST_IMAGE))

docker-built: .built

.built: $$(shell find . -maxdepth 0 -type f -not -name .built -not -name .pushed)
	-docker pull $(DOCKER_IMAGE)
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMAGE) $(@D)

	touch $@

docker-push: .pushed

.pushed: .built
	docker push $(DOCKER_IMAGE)

	# Push alias for dist images with the timestamp and hash of the current git commit
	([[ "$(DOCKER_IMAGE)" == *":dist" ]] && docker push $(DOCKER_DIST_IMAGE)) || :

	touch $@
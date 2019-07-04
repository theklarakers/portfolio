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

include Makefile.vars.mk
include make/help.mk
include make/crypt.mk
include make/docker.mk
include make/kubernetes.mk

node_modules/.installed: ENV = dev
node_modules/.installed: .built-dev | ~/.npm
	$(DOCKER_RUN) npm install

	touch $@

.built-dist: ENV=dist
.built-dist: node_modules/.installed

.PHONY: npm-update
npm-update: DOCKER_RUN_ARGS += -it
npm-update: .built | ~/.npm
	$(DOCKER_RUN) sh

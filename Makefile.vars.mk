# Default shell to use
SHELL := /bin/bash -o pipefail

# Project root directory
export ROOT_DIR := $(abspath .)

# Project name
export PROJECT_NAME := theklarakers

export KUBE_APP_NAMESPACE := theklarakers

MAKE_INCLUDES_DIR := make

DEPENDENCIES := \
	package-lock.json \
	package.json \
	gulpfile.js

KUBE_YAMLS := docker/kube/kube.yaml
KUBE_DEPLOY_WAIT_RESOURCES := deploy/web
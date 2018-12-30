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
KUBE_YAML_PRODUCTION_ISSUER := docker/kube/production_issuer.yaml
KUBE_YAML_STAGING_ISSUER := docker/kube/staging_issuer.yaml
KUBE_DEPLOY_WAIT_RESOURCES := deploy/web
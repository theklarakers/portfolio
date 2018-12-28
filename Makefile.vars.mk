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
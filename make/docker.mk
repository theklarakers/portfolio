ENV ?= dev
DOCKER_IMAGE_PREFIX ?= jvisser/$(PROJECT_NAME)
DOCKER_IMAGE = $(DOCKER_IMAGE_PREFIX)-website:$(ENV)
DOCKER_BUILD_ARGS += --cache-from $(DOCKER_IMAGE)
# Prevent pulling a base image from Docker Hub that has just been built locally
DOCKER_BUILD_ARGS += $(shell echo "$?" | grep -q \.built || echo "--pull")
# Tag :dist images also with DOCKER_DEPLOY_TAG (commit hash + timestamp)
export DOCKER_DEPLOY_TAG  ?= $(shell git --no-pager show -s --format="%h")
DOCKER_DIST_IMAGE         = $(subst :dist,:$(DOCKER_DEPLOY_TAG),$(DOCKER_IMAGE))
DOCKER_BUILD_ARGS        += $(if $(findstring :dist,$(DOCKER_IMAGE)),-t $(DOCKER_DIST_IMAGE))

DOCKER_RUN_ARGS ?=
export HOST_UID = $(shell id -u)
export HOST_GID = $(shell id -g)
DOCKER_RUN = docker run \
	--rm $(DOCKER_RUN_ARGS) \
	-u $(HOST_UID):$(HOST_GID) \
	-e HOME=/home \
	-v ~/.npm:/home/.npm \
	-v $(ROOT_DIR):/app \
	$(DOCKER_IMAGE)

.PHONY: docker-login
docker-login:
	@echo "$(DOCKER_PASSWORD)" | docker login -u $(DOCKER_USERNAME) --password-stdin

## docker-build: Will build the image (with dist and git hash tag)
docker-build: .built-dist

.built-dist: ENV ?= dist
.built-dist: Dockerfile
	docker build $(DOCKER_BUILD_ARGS) --tag $(DOCKER_IMAGE) --file $< $(ROOT_DIR)

	touch $@

.built-dev: Dockerfile.dev
	docker build $(DOCKER_BUILD_ARGS) --tag $(DOCKER_IMAGE) --file $< $(ROOT_DIR)

	touch $@

## docker-push: Will push the images to Docker Hub
docker-push: .pushed

.pushed: .built-dist
	docker push $(DOCKER_IMAGE)

	# Push alias for dist images with the timestamp and hash of the current git commit
	([[ "$(DOCKER_IMAGE)" == *":dist" ]] && docker push $(DOCKER_DIST_IMAGE)) || :

	touch $@

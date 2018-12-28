DOCKER_IMAGE_PREFIX ?= jvisser/$(PROJECT_NAME)
DOCKER_IMAGE = $(DOCKER_IMAGE_PREFIX)-website:dist
DOCKER_BUILD_ARGS += --cache-from $(DOCKER_IMAGE)
# Prevent pulling a base image from Docker Hub that has just been built locally
DOCKER_BUILD_ARGS += $(shell echo "$?" | grep -q \.built || echo "--pull")
# Tag :dist images also with DOCKER_DEPLOY_TAG (commit hash + timestamp)
export DOCKER_DEPLOY_TAG  ?= $(shell git --no-pager show -s --format="%h")
DOCKER_DIST_IMAGE         = $(subst :dist,:$(DOCKER_DEPLOY_TAG),$(DOCKER_IMAGE))
DOCKER_BUILD_ARGS        += $(if $(findstring :dist,$(DOCKER_IMAGE)),-t $(DOCKER_DIST_IMAGE))

export HOST_UID = $(shell id -u)
export HOST_GID = $(shell id -g)
DOCKER_RUN = docker run --rm -u $(HOST_UID):$(HOST_GID) -e HOME=/home

## docker-build: Will build the image (with dist and git hash tag)
docker-build: .built

.built: $$(shell find . -maxdepth 0 -type f -not -name .built -not -name .pushed)
	-docker pull $(DOCKER_IMAGE)
	docker build $(DOCKER_BUILD_ARGS) -t $(DOCKER_IMAGE) $(@D)

	touch $@

## docker-push: Will push the images to Docker Hub
docker-push: .pushed

.pushed: .built
	docker push $(DOCKER_IMAGE)

	# Push alias for dist images with the timestamp and hash of the current git commit
	([[ "$(DOCKER_IMAGE)" == *":dist" ]] && docker push $(DOCKER_DIST_IMAGE)) || :

	touch $@

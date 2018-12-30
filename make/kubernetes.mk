ifndef KUBE_APP_NAMESPACE
	$(error Please define and export the kubernetes namespace (alphanumeric characters only) in a variable named KUBE_APP_NAMESPACE)
endif

include $(MAKE_INCLUDES_DIR)/kubernetes.vars.mk

$(MAKE_INCLUDES_DIR)/kubernetes.vars.mk: $(MAKE_INCLUDES_DIR)/kubernetes.vars.mk.enc | $(CRYPT_SECRET)
	$(__DECRYPT)

KUBE_CONFIG_DIR := $(ROOT_DIR)/.kube
KUBE_CONFIG := .kube/kubeconfig
KUBECTL_DEPS := $(KUBE_CONFIG)

KUBECTL_ARGS ?= --kubeconfig .kube/kubeconfig
# Shortcuts for invoking the kubectl binaries
KUBECTL_DOCKER_ARGS ?=
KUBECTL = $(DOCKER_RUN) \
	-v $(KUBE_CONFIG_DIR):/home/.kube \
	-v $(ROOT_DIR):/workspace \
	--workdir /workspace \
	$(KUBECTL_DOCKER_ARGS) \
	lachlanevenson/k8s-kubectl:v1.12.2 \
	$(KUBECTL_ARGS)

# An alias to kubectl which includes the namespace
KUBECTL_NS = $(KUBECTL) --namespace $(KUBE_APP_NAMESPACE)

KUBE_CLUSTER_URL := https://api.digitalocean.com/v2/kubernetes/clusters/$(KUBE_CLUSTER_ID)
KUBE_CLUSTER_CONFIG_URL := $(KUBE_CLUSTER_URL)/kubeconfig

## .kube/kubeconfig: Retrieve a Kubeconfig file for use with a Kubernetes cluster
$(KUBE_CONFIG):
	@echo "Loading configuration file"
	@mkdir -p .kube
	@curl --silent \
		  --show-error \
		  --fail \
		  --url $(KUBE_CLUSTER_CONFIG_URL) \
		  -H "Authorization: Bearer $(DIGITAL_OCEAN_TOKEN)" \
		  -o $(KUBE_CONFIG)
	@echo "Done loading configuration file!"

## dry-run-deployment: Output the deployment configuration as it would be send to Kubernetes
dry-run-deployment: $(KUBE_YAMLS)
	cat $(KUBE_YAMLS) | envsubst

## deploy: Deploy the kubernetes components defined in the yaml files as specified in $(KUBE_YAMLS)
.PHONY: deploy
deploy: KUBECTL_DOCKER_ARGS += --interactive
deploy: $(KUBE_YAMLS) | $(KUBE_CONFIG) app-namespace
	cat $(KUBE_YAMLS) | envsubst | $(KUBECTL) apply -f -
	/bin/bash -ec ' \
		if ! test -z "$(KUBE_DEPLOY_WAIT_RESOURCES)"; then \
			for RESOURCE_ID in $$(echo "$(KUBE_DEPLOY_WAIT_RESOURCES)" | tr " " "\n"); do \
				$(KUBECTL_NS) rollout status $$RESOURCE_ID; \
			done; \
		fi \
	'

# Create the application namespace in the kubernetes cluster
.PHONY: app-namespace
app-namespace: | $(KUBECTL_DEPS)
	$(SHELL) -c '\
		$(KUBECTL) get namespace $(KUBE_APP_NAMESPACE) > /dev/null 2>&1 || \
		$(KUBECTL) create namespace $(KUBE_APP_NAMESPACE) \
	'

## kube-list-pods: Show running pods in kubernetes cluster namespace
kube-list-pods: $(KUBECTL_DEPS)
	$(KUBECTL_NS) get pods

## kube-list-deployments: Show deployments in kubernetes cluster namespace
kube-list-deployments: $(KUBECTL_DEPS)
	@$(KUBECTL_NS) get deployments

## kube-list-of-pods-in-all-namespaces: Show running pods in all namespace
kube-list-of-pods-in-all-namespaces: $(KUBECTL_DEPS)
	$(KUBECTL) get pods --all-namespaces

.PHONY: entrypoint-kubectl
entrypoint-kubectl: KUBE_DOCKER_ARGS += --tty --interactive
entrypoint-kubectl: | $(KUBECTL_DEPS)
	$(KUBECTL) $(ARGS)

## deploy-lets-encrypt-staging-issuer: Deploy the kubernetes component to deploy the let's encrypt staging issuer
.PHONY: deploy-lets-encrypt-staging-issuer
deploy-lets-encrypt-staging-issuer: KUBECTL_DOCKER_ARGS += --interactive
deploy-lets-encrypt-staging-issuer: $(KUBE_YAMLS) | $(KUBE_CONFIG) app-namespace
	cat $(KUBE_YAML_STAGING_ISSUER) | envsubst | $(KUBECTL) apply -f -
	/bin/bash -ec ' \
		if ! test -z "$(KUBE_DEPLOY_WAIT_RESOURCES)"; then \
			for RESOURCE_ID in $$(echo "$(KUBE_DEPLOY_WAIT_RESOURCES)" | tr " " "\n"); do \
				$(KUBECTL_NS) rollout status $$RESOURCE_ID; \
			done; \
		fi \
	'

## deploy-lets-encrypt-production-issuer: Deploy the kubernetes component to deploy the let's encrypt production issuer
.PHONY: deploy-lets-encrypt-production-issuer
deploy-lets-encrypt-production-issuer: KUBECTL_DOCKER_ARGS += --interactive
deploy-lets-encrypt-production-issuer: $(KUBE_YAMLS) | $(KUBE_CONFIG) app-namespace
	cat $(KUBE_YAML_PRODUCTION_ISSUER) | envsubst | $(KUBECTL) apply -f -
	/bin/bash -ec ' \
		if ! test -z "$(KUBE_DEPLOY_WAIT_RESOURCES)"; then \
			for RESOURCE_ID in $$(echo "$(KUBE_DEPLOY_WAIT_RESOURCES)" | tr " " "\n"); do \
				$(KUBECTL_NS) rollout status $$RESOURCE_ID; \
			done; \
		fi \
	'
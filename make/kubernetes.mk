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
	-it \
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

## kube-list-pods: Show running pods in kubernetes cluster namespace
kube-create-namespace: $(KUBECTL_DEPS)
	$(KUBECTL_NS) create namespace $(KUBE_APP_NAMESPACE)

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
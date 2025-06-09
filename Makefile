# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

## Tool Versions
KRO_VERSION ?= v0.3.0

.PHONY: all
all: build

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Install
.PHONY: install
install: crds kro rgds ## Install everything.

.PHONY: kro
kro: ## Install kro Helm chart.
	@echo "Installing kro Helm chart version ${KRO_VERSION}..."
	@helm install kro oci://ghcr.io/kro-run/kro/kro \
  		--namespace kro \
  		--create-namespace \
  		--version=${KRO_VERSION}

.PHONY: crds
crds: ## Install Custom Resource Definitions.
	@echo "Installing Custom Resource Definitions..."
	@kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_buckets.yaml
	@kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_gitrepositories.yaml
	@kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmrepositories.yaml
	@kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmcharts.yaml
	@kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_ocirepositories.yaml
	@kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-controller/refs/heads/main/config/crd/bases/helm.toolkit.fluxcd.io_helmreleases.yaml

.PHONY: rgds
rgds: ## Install Resource Graph Definitions.
	@echo "Installing Resource Graph Definitions..."
	@kubectl apply -f resources/source-operator.yaml
	@kubectl apply -f resources/helm-operator.yaml
	@kubectl apply -f resources/helm-installer.yaml

##@ Upgrade
.PHONY: upgrade
upgrade: upgrade-kro ## Upgrade all components.

.PHONY: upgrade-kro
upgrade-kro: ## Upgrade kro Helm chart.
	@echo "Upgrading kro Helm chart to version ${KRO_VERSION}..."
	@helm upgrade kro oci://ghcr.io/kro-run/kro/kro \
  		--namespace kro \
  		--version=${KRO_VERSION}

##@ Uninstall
.PHONY: uninstall
uninstall: undeploy uninstall-rgds uninstall-kro uninstall-crds ## Uninstall everything.

.PHONY: uninstall-kro
uninstall-kro: ## Uninstall kro Helm chart.
	@echo "Uninstalling kro Helm chart..."
	@helm uninstall kro --namespace kro

.PHONY: uninstall-crds
uninstall-crds: ## Uninstall Custom Resource Definitions.
	@echo "Uninstalling Custom Resource Definitions..."
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_buckets.yaml
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_gitrepositories.yaml
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmrepositories.yaml
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmcharts.yaml
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_ocirepositories.yaml
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-controller/refs/heads/main/config/crd/bases/helm.toolkit.fluxcd.io_helmreleases.yaml

.PHONY: uninstall-rgds
uninstall-rgds: ## Uninstall Resource Graph Definitions.
	@echo "Uninstalling Resource Graph Definitions..."
	@kubectl delete -f resources/source-operator.yaml
	@kubectl delete -f resources/helm-operator.yaml
	@kubectl delete -f resources/helm-installer.yaml

##@ Deployment
.PHONY: deploy
deploy: deploy-helm ## Deploy all components.

.PHONY: undeploy
undeploy: undeploy-helm ## Undeploy all components.

.PHONY: deploy-helm
deploy-helm: ## Deploy the Helm installer.
	@echo "Deploying the Helm installer..."
	@kubectl apply -f deploy/helm.yaml

.PHONY: undeploy-helm
undeploy-helm: ## Undeploy the Helm installer.
	@echo "Undeploying the Helm installer..."
	@kubectl delete -f deploy/helm.yaml

# Setting SHELL to bash allows bash commands to be executed by recipes.
# Options are set to exit when a recipe line exits non-zero or a piped command fails.
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

## Tool Versions
KRO_VERSION ?= 0.3.0

.PHONY: all
all: build

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Install
.PHONY: install
install: crds kro rgds deploy-helm ## Install everything, including Helm installer, but not apps.

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
	@kubectl apply -f resources/postgres.yaml

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
	@helm uninstall kro --namespace kro || true

.PHONY: uninstall-crds
uninstall-crds: ## Uninstall Custom Resource Definitions.
	@echo "Uninstalling Custom Resource Definitions..."
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_buckets.yaml || true
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_gitrepositories.yaml || true
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmrepositories.yaml || true
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmcharts.yaml || true
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_ocirepositories.yaml || true
	@kubectl delete -f https://raw.githubusercontent.com/fluxcd/helm-controller/refs/heads/main/config/crd/bases/helm.toolkit.fluxcd.io_helmreleases.yaml || true

.PHONY: uninstall-rgds
uninstall-rgds: ## Uninstall Resource Graph Definitions.
	@echo "Uninstalling Resource Graph Definitions..."
	@kubectl delete -f resources/postgres.yaml || true
	@kubectl delete -f resources/helm-installer.yaml || true
	@kubectl delete -f resources/helm-operator.yaml || true
	@kubectl delete -f resources/source-operator.yaml || true

##@ Deployment
.PHONY: deploy
deploy: deploy-helm deploy-postgres ## Deploy all components.

.PHONY: undeploy
undeploy: undeploy-postgres undeploy-helm ## Undeploy all components.

.PHONY: deploy-helm
deploy-helm: ## Deploy the Helm installer.
	@echo "Deploying the Helm installer..."
	@kubectl apply -f deploy/helm.yaml

.PHONY: undeploy-helm
undeploy-helm: ## Undeploy the Helm installer.
	@echo "Undeploying the Helm installer..."
	@kubectl delete -f deploy/helm.yaml || true

.PHONY: deploy-postgres
deploy-postgres: ## Deploy PostgreSQL.
	@echo "Deploying PostgreSQL..."
	@kubectl apply -f deploy/postgres.yaml

.PHONY: undeploy-postgres
undeploy-postgres: ## Undeploy PostgreSQL.
	@echo "Undeploying PostgreSQL..."
	@kubectl delete -f deploy/postgres.yaml || true

##@ Status
.PHONY: status
status: status-kro status-rgd status-helm status-postgres ## Display the status of the deployment.

.PHONY: status-kro
status-kro: ## Display the status of the kro Helm chart.
	@echo "Checking the status of the kro Helm chart..."
	@helm status kro --namespace kro || true
	@echo "Checking the status of the kro pods..."
	@kubectl get pods -n kro || true

.PHONY: status-rgd
status-rgd: ## Display the status of the Resource Graph Definitions.
	@echo "Checking the status of the Resource Graph Definitions..."
	@kubectl get rgd || true

.PHONY: status-helm
status-helm: ## Display the status of the Helm installer.
	@echo "Checking the status of the Helm installer..."
	@kubectl get helminstaller || true
	@echo "Checking the status of the Helm repositories..."
	@kubectl get helmrepository || true
	@echo "Checking the status of the Helm releases..."
	@kubectl get helmrelease || true

.PHONY: status-postgres
status-postgres: ## Display the status of PostgreSQL.
	@echo "Checking the status of PostgreSQL..."
	@kubectl get postgres || true

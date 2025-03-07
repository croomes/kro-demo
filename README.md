# Kube Resource Operator (kro)

## Install

Follow [https://kro.run/docs/getting-started/Installation/]

## Get latest version

```console
export KRO_VERSION=$(curl -sL \
    https://api.github.com/repos/kro-run/kro/releases/latest | \
    jq -r '.tag_name | ltrimstr("v")'
  )
```

## Install kro

```console
helm install kro oci://ghcr.io/kro-run/kro/kro \
  --namespace kro \
  --create-namespace \
  --version=${KRO_VERSION}
```

## Install Helm CRD

Note: this should move to the Helm RGD.

```console
kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_buckets.yaml
kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_gitrepositories.yaml
kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmrepositories.yaml
kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_helmcharts.yaml
kubectl apply -f https://raw.githubusercontent.com/fluxcd/source-controller/refs/heads/main/config/crd/bases/source.toolkit.fluxcd.io_ocirepositories.yaml
kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-controller/refs/heads/main/config/crd/bases/helm.toolkit.fluxcd.io_helmreleases.yaml
```

## Create kro ResourceGraphDefinitions

These are the building blocks that can be installed. `HelmInstaller` is a
composite of `SourceOperator` and `HelmOperator`.

```console
kubectl apply -f resources/source-operator.yaml
kubectl apply -f resources/helm-operator.yaml
kubectl apply -f resources/helm-installer.yaml
```

## Create HelmInstaller instance

This installs the Helm installer.

```console
kubectl apply -f deploy/helm.yaml
```

## Questions

1. How are ResourceGraphDefinition updates managed? Create a new version for
   breaking changes, and conversion webhooks?

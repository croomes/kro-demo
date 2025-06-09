# Kube Resource Operator (kro)

## Help

`make help` describes all `make` targets.

## Install

Running `make install` will install the kro Helm chart, CRD dependencies, and
the demo Resource Graph Definitions (RGDs).

## Upgrading

The kro version is hardcoded in the Makefile. To get the latest release, run:

```console
    curl -sL https://api.github.com/repos/kro-run/kro/releases/latest | \
    jq -r '.tag_name | ltrimstr("v")'
```

Update `KRO_VERSION` in the Makefile, and run `make upgrade`.

## Create HelmInstaller instance

This installs the Helm installer.

```console
make deploy-helm
```

## Uninstall

To uninstall everything, run `make uninstall`. This will remove all apps too.

## Questions

1. How are ResourceGraphDefinition updates managed? Create a new version for
   breaking changes, and conversion webhooks?

# Kube Resource Operator (kro)

## Help

`make help` describes all `make` targets.

## Install

Running `make install` will install the kro Helm chart, CRD dependencies,
the demo Resource Graph Definitions (RGDs) and the Helm installer.

## Upgrading

The kro version is hardcoded in the Makefile. To get the latest release, run:

```console
    curl -sL https://api.github.com/repos/kro-run/kro/releases/latest | \
    jq -r '.tag_name | ltrimstr("v")'
```

Update `KRO_VERSION` in the Makefile, and run `make upgrade`.

## Install Postgres

This installs Postgres.

```console
make deploy-postgres
```

Or, to install manually, customize `deploy/postgres.yaml` and apply:

```console
kubectl apply -f deploy/postgres.yaml`
```

## Uninstall

To uninstall everything, run `make uninstall`. This will remove all apps too.

## Questions

1. How are ResourceGraphDefinition updates managed? Create a new version for
   breaking changes, and conversion webhooks?

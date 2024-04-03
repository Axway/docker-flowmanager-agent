# AMPLIFY Flow Manager Service Agent Helm Chart

## Introduction

This chart bootstraps an Flow Manager agent deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

  - Kubernetes 1.4+
  - Helm v2.9+ or v3 

## Installing the Chart

To install the chart with the release name `flowmanager-agent`:

```console
$ helm upgrade --install flowmanager-agent ./flowmanager-agent \
  --namespace=<your_namespace>
```

The command deploys flowmanager-agent on the Kubernetes cluster in the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `flowmanager-agent` deployment:

```console
$ helm delete flowmanager-agent
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the flowmanager-agent chart and their default values.

Parameter | Description | Default
--- | --- | ---
`replicaCount` | Number of replicas deployed | `2`
`image.repository` | Image repository for docker image | `flowmanager-agent`
`image.tag` | Image tag used for the deployment | `latest`
`image.pullPolicy` | Pull Policy Action for docker image | `IfNotPresent`
`imagePullSecrets` | Secret used for Pulling image | `""`
`nameOverride` | New name use for the deployment | `""`
`fullnameOverride` | Name use for the release| `""`
`serviceAccount.create` | create custom service account for the deployment | `false`
`serviceAccount.name` | Service Account name used for the deployment | `""`
`rbac.create` | create custom role base access control (RBAC) for the deployment | `false`
`pspEnable.create` | create custom pod security policy for user account | `false`
`podAnnotations` | Annotations for pods (example prometheus scraping) | `{}`
`securityContext` | User used inside the container | `{}`
`podSecurityContext` | group used inside the container | `{}`
`resources.limits` | Limitation for ressources usage | `{}`
`resources.requests` | Ressources requested per the container | `cpu: 100 / memory: 100Mi`
`livenessProbe` | Liveness probes to know when to restart a Container | `{}`
`readinessProbe` | Readiness probes to know when a Container is ready to start accepting traffic | `{}`
`nodeSelector` | Label used to deploy on specific node | `{}`
`tolerations` |  Tolerations are applied to pods, and allow (but do not require) the pods to schedule onto nodes with matching taints | `[]`
`affinity` | Affinity rules between each pods | `{}`
`config.name` | Name provided to flowmanager-agent | `GLOBAL`
`config.acceptEula` | Licence acceptance for flowmanager-agent | `false`
`config.server` | Remote server targeted for flowmanager-agent | `""`
`config.insecure` | Option for usage secure or insecure | `""`
`config.cacert` | Optional path for certs | `""`
`config.dosaKeyPassword` | Password for passphrase on you key | `""`
`config.count` | Parallel connections | `2`
`config.sendLogs` | Sending logs | `true`
`extraConfig` | Adding variables optional for container | `[]`
`secrets.dosa` | Secret used during the deployment | `dosa-secrets`




These parameters can be passed via Helm's `--set` option
```console
$ helm upgrade --install flowmanager-agent ./flowmanager-agent \
  --namespace=<your_namespace> \
  --set image.repository="flowmanager-agent" \
  --set image.tag="stable" \
  --set config.name="GLOBAL" \
  --set config.acceptEULA=ACCEPT_EULA:-"true" 
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
$ helm upgrade --install flowmanager-agent  ./flowmanager-agent  --namespace=<your_namespace> -f <your_values.yaml>
```

> **Tip**: You can use the default [values.yaml](values.yaml)
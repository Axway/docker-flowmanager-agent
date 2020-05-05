# AMPLIFY Flow Manager Agent

The purpose of this agent is to be create a bridge between AMPLIFY Flow Manager Service and managed product installed in secured zones.

## Before you begin

This document assumes a basic understanding of core Docker concepts such as containers, container images, and basic Docker commands.
If needed, see [Get started with Docker](https://docs.docker.com/get-started/) for a primer on container basics.

## Prerequisites

- a docker engine>1.13 (with docker-compose >1.17 ) or kubernetes >1.13 or openshift 3,4 or helm 2 or 3
- retrieve flowmanager-agent docker image from [https//support.axway.com] as `flowmanager-agent.tgz`

## Upload you image

- `docker load --input flowmanager-agent.tgz` the repository here supposes that the image is called `axway/flowmanager-agent:latest`

## Basic Configuration

```sh
IMAGE=axway/flowmanager-agent:latest   # from https//support.axway.com
NAME=GLOBAL                            # Choose an appropriate name for your agent/network zone
DOSA_CERT=/conf/dosa-public.pem        # generate a x509 rsa:4096 key pair to be used to create service account
DOSA_KEY=/conf/dosa-key.pem            #
DOSA_KEY_PASSWORD=""                   # If dosa-key is protected
DOSA=/conf/dosa.json                   # Generated when creating service account on AMPLIFY platform (https://apicentral.axway.com/access/service-accounts)
```

### generate and register DOSA key in AMPLIFY platform

- generate a pubkey/priv key in `./conf/dosa-key.pem` `./conf/dosa-public.pem`
  - `openssl req -x509 -newkey rsa:4096 -keyout "./conf/dosa-key.pem" -out "./conf/dosa-public.pem" -nodes  -days 10 > /dev/null 2>&1`
- create a Service Account in [https://apicentral.axway.com/access/service-accounts]
  - you need to have an administrator role
- copy the generated DOSA json file in `./conf/dosa.json`

## Deployment

### Alternative 1 : using docker-compose (docker, swarm...)

edit `./compose/.env`

```sh
cat > ./compose/.env <<EOF
IMAGE=axway/flowmanager-agent:latest
NAME=GLOBAL
ACCEPT_EULA=True
EOF
cd ./compose

docker-compose up -d
```

### Alternative 2 : using k8s orchestrator (plain kubernetes, openshift, ...)

#### using plain k8s files

please edit `./k8s/flowmanager-agent-deployment.yml`
customize
- `spec.template.spec.containers[0].image="axway/flowmanager-agent:latest"`
- `spec.template.spec.containers[0].env[name="name"].value="GLOBAL"`
- `spec.template.spec.containers[0].env[name="ACCEPT_EULA"]="true"` if you accept the EULA

```sh
    kubectl create secret generic dosa-secrets --from-file=../conf/dosa-key.pem --from-file=../conf/dosa-public.pem --from-file=../conf/dosa.json
    kubectl create -f ./k8s/flowmanager-agent-deployment.yml
```

#### using helm

Please follow the configuration step on this [README](helm/flowmanager-agent/README.md)

```sh
    kubectl create secret generic dosa-secrets --from-file=../conf/dosa-key.pem --from-file=../conf/dosa-public.pem --from-file=../conf/dosa.json
    helm upgrade --install DEPLOYMENT-NAME ./helm/flowmanager-agent --set repository.image=flowmanager-agent,repository.tag=latest,name=AGENT_NAME,acceptEULA=true
    helm delete DEPLOYMENT-NAME
```

## Verify successful connection to the bridge

```sh
docker-compose logs
[2020-04-28T10:44:00.591963250Z]  INFO CLI-???????????????- Agent successfully connected to bridge
```

```sh
kubectl logs deployment/flowmanager-agent
[2020-04-28T10:44:00.591963250Z]  INFO CLI-???????????????- Agent successfully connected to bridge
```

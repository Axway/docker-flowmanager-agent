#!/bin/bash
#

#!/bin/bash
#

HELM_NAME="flowmanager-agent"

set -uoe pipefail

COL_MSG="\033[92m"
COL_CLEAR="\033[0m"

DEBUG() {
    echo
    echo -e "$COL_MSG> $@$COL_CLEAR"
    $@
}

if [ -f "./.env" ]; then
    . ./.env
fi

case "${1:-}" in
    "create")
        DEBUG kubectl create secret generic dosa-secrets --from-file=../conf/dosa-key.pem --from-file=../conf/dosa-public.pem --from-file=../conf/dosa.json
        DEBUG kubectl get secrets
        DEBUG helm upgrade --install "$HELM_NAME" ./flowmanager-agent --set image.repository=${REPOSITORY:-flowmanager-agent},image.tag=${TAG:-"stable"},config.name=${NAME:-"GLOBAL"},config.acceptEULA=${ACCEPT_EULA:-"false"},config.server=${SERVER:-},config.insecure=${INSECURE:="false"}
    ;;

    "delete")
        DEBUG helm delete $HELM_NAME
        DEBUG kubectl delete secret dosa-secrets
    ;;

    "wait-started")
        DEBUG kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=flowmanager-agent --timeout=10s
    ;;

    "wait-delete")
        DEBUG kubectl wait --for=delete pod -l app.kubernetes.io/name=flowmanager-agent --timeout=10s
    ;;

    "replace")
        DEBUG kubectl replace secret generic dosa-secrets --from-file=../conf/dosa-key.pem --from-file=../conf/dosa-public.pem --from-file=../conf/dosa.json
        DEBUG helm upgrade $HELM_NAME ./flowmanager-agent
    ;;

    "status")
        DEBUG kubectl get secrets dosa-secrets || true
        DEBUG kubectl get deployment/flowmanager-agent || true
    ;;

    "inspect")
        DEBUG kubectl describe secrets dosa-secrets
        DEBUG kubectl describe deployment/flowmanager-agent
    ;;

    "logs")
        DEBUG kubectl logs deployment/flowmanager-agent
    ;;

    *)
        if [ ! -z "${1:-}" ]; then
            echo "unsupported command $1"
        fi
        echo "$0 create | delete | replace | status | inspect | logs | wait-ready"
    ;;
esac

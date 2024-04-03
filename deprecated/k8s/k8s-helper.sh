#!/bin/bash
#

SUBST="" # using subtitution?

set -uoe pipefail

COL_MSG="\033[92m"
COL_CLEAR="\033[0m"

DEBUG() {
    echo
    echo -e "$COL_MSG> $@$COL_CLEAR"
    "$@"
}

subst() {
    DEBUG yq --in-place -y "${1}" ./flowmanager-agent-deployment.yml.subst
}

substEnv() {
    DEBUG subst '.spec.template.spec.containers[0].env=[ .spec.template.spec.containers[0].env[] | select(.name=="'"$1"'").value="'"$2"'"]'
}

substs() {
    cp ./flowmanager-agent-deployment.yml ./flowmanager-agent-deployment.yml.subst
    DEBUG subst '.spec.template.spec.containers[0].image="'"$REPOSITORY:$TAG"'"'
    DEBUG substEnv "ACCEPT_EULA" "$ACCEPT_EULA"
    DEBUG substEnv "NAME" "$NAME"
    DEBUG substEnv "INSECURE" "$INSECURE"
    DEBUG substEnv "INSECURE" "$INSECURE"
    DEBUG substEnv "SERVER" "$SERVER"
}

if [ -f "./.env" ]; then
    . ./.env
    SUBST=".subst"
fi

case "${1:-}" in
    "subst")
        substs
    ;;

    "create")
        DEBUG kubectl create secret generic dosa-secrets --from-file=../conf/dosa-key.pem --from-file=../conf/dosa-public.pem --from-file=../conf/dosa.json
        DEBUG kubectl get secrets
        DEBUG kubectl create -f ./flowmanager-agent-deployment.yml$SUBST
        DEBUG kubectl get deployment/flowmanager-agent
    ;;

    "wait-ready")
        DEBUG kubectl wait --for=condition=Ready pod -l app=flowmanager-agent --timeout=10s
    ;;

    "delete")
        DEBUG kubectl delete -f ./flowmanager-agent-deployment.yml$SUBST --wait=true
        DEBUG kubectl delete secret dosa-secrets
    ;;

    "replace")
        DEBUG kubectl replace secret generic dosa-secrets --from-file=../conf/dosa-key.pem --from-file=../conf/dosa-public.pem --from-file=../conf/dosa.json
        DEBUG kubectl replace -f ./flowmanager-agent-deployment.yml$SUBST
    ;;

    "status")
        DEBUG kubectl get secrets dosa-secrets
        DEBUG kubectl get deployment/flowmanager-agent
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

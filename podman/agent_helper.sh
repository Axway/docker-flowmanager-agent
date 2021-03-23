#!/bin/bash
set -euo pipefail

# Setup and run the app.
# Example: ./flowmanager.sh [setup/start/restart/stop/help...]

PROJECT_NAME="flowmanager"

# Install the container(s) for agent
function start() {
podman play kube ./agent.yml
echo "FlowManager Agent was installed."
}

# Stop the container(s) for agent
function stop() {
podman pod stop agent_pod
echo "Pod 'flowmanager_pod' was stopped"
}

# Delete the container(s) for agent
function delete() {
podman pod rm -f agent_pod
echo "Pod 'agent_pod' was deleted"
}

# How to use the script
function usage() {
    echo "--------"
    echo " HELP"
    echo "--------"
    echo "Usage: ./$PROJECT_NAME [option]"
    echo "  options:"
	echo "    start    : Start agent"
	echo "    stop     : Stop agent"
	echo "    delete   : Delete agent"
    echo "    help     : Show the usage of the script file"
    echo ""
    exit
}

[[ $# -eq 0 ]] && usage

# Menu
if [[ $@ ]]; then
    while (( $# ))
    do
        case "$1" in
		     start)
                start
                shift
                ;;
		     stop)
                stop
                shift
                ;;
		     delete)
                delete
                shift
                ;;
            help)
                usage
                exit 0
                ;;
            *)
                error_message "ERROR: Invalid option $1. Type help option for more information"
                exit 0
                ;;
        esac
    done
else
    usage
    exit 0
fi

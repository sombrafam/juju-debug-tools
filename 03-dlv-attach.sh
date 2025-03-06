#!/bin/bash -x

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars || echo "ERROR: Failed to source vars." && exit 1
source "$repo_folder"/helpers

for node in ${DEBUG_TARGET_MACHINES}; do
    controller_ip=`juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "hostname -I | awk '{print $1}'"`
    juju_pid=`juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "pgrep jujud"|tr -d '\r'`
    juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "sudo /var/lib/juju/agents/machine-${node}/dlv --listen=:789${node} --headless=true --api-version=2 attach $juju_pid"
done
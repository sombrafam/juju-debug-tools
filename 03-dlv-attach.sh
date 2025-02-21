#!/bin/bash -x

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars
source "$repo_folder"/helpers

for node in 0 1 2; do
    controller_ip=`juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "hostname -I | awk '{print $1}'"`
    juju_pid=`juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "pgrep jujud"`
    juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "sudo /var/lib/juju/agents/machine-${node}/dlv --listen=:789${node} --headless=true --api-version=2 attach $juju_pid"
done
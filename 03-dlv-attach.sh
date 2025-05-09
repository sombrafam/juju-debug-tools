#!/bin/bash

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars || { echo "ERROR: Failed to source vars."; exit 1; }
source "$repo_folder"/helpers

for node in ${CONTROLLER_IPS}; do
    machine_id=`ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "ls /var/lib/juju/agents/| grep machine|cut -d'-' -f'2'"`
    juju_pid=`ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "pgrep jujud"|tr -d '\r'`

    echo "INFO: Attaching dlv to $node machine-$machine_id"
    echo "INFO: Connect to the dlv server with: dlv connect $node:789${machine_id}"
    ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "sudo /var/lib/juju/tools/machine-${machine_id}/dlv --listen=:789${machine_id} --headless=true --api-version=2 attach $juju_pid"
done
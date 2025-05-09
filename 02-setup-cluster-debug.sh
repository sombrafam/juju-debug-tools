#!/bin/bash -x

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars || { echo "ERROR: Failed to source vars."; exit 1; }
source "$repo_folder"/helpers

# copy the binaries to the controller nodes /tmp folder and install them in the right place
for node in ${CONTROLLER_IPS}; do
    machine_id=`ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "ls /var/lib/juju/agents/| grep machine|cut -d'-' -f'2'"`
    echo "INFO: Copying binaries to $node machine-$machine_id"
    scp "${HOME}/juju-binaries/jujud" "$node":/tmp/jujud
    scp "${HOME}/juju-binaries/dlv" "$node":/tmp/dlv

    ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "sudo mv /tmp/jujud /var/lib/juju/tools/machine-${machine_id}/jujud"
    ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "sudo mv /tmp/dlv /var/lib/juju/tools/machine-${machine_id}/dlv"
    # restart juju on the controller nodes
    ssh -i ~/.local/share/juju/ssh/juju_id_rsa "$node" "sudo systemctl restart jujud-machine-${machine_id}.service"
done

# open the security group in the openstack security group to allow access to the juju controller
# if you are using a network with security groups enabled.

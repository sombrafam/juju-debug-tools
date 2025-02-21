#!/bin/bash -x

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars
source "$repo_folder"/helpers

juju status --format=short &> /dev/null || (echo "ERROR: Failed to get juju status, exiting.." && exit 1)

# copy the binaries to the controller nodes /tmp folder and install them in the right place
for node in 0 1 2; do
    juju scp -m ${JUJU_CONTROLLER}:controller "${HOME}/juju-binaries/jujud" "$node":/tmp/jujud
    juju scp -m ${JUJU_CONTROLLER}:controller "${HOME}/juju-binaries/dlv" "$node":/tmp/dlv

    juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "sudo mv /tmp/jujud /var/lib/juju/agents/machine-${node}/jujud"
    juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "sudo mv /tmp/dlv /var/lib/juju/agents/machine-${node}/dlv"
    # restart juju on the controller nodes
    juju ssh -m ${JUJU_CONTROLLER}:controller "$node" "sudo systemctl restart jujud-machine-${node}.service"
done

# open the security group in the openstack security group to allow access to the juju controller
# if you are using a network with security groups enabled.

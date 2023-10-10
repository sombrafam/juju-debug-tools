#!/bin/bash

source vars
source helpers

cwd=$(pwd)
repo_name=$(basname $cwd)

ssh ubuntu@${BASTION_IP} 'mkdir -p kubernetes-binaries '"$repo_name" ""

rsync --checksum -avz ../$repo_name/ ubuntu@${BASTION_IP}:$repo_name/

cd "$KUBERNETES_FOLDER" || exit 1
make all
rsync --checksum -avz _output/local/bin/linux/amd64/ ubuntu@${BASTION_IP}:kubernetes-binaries/


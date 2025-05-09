#!/bin/bash

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars || { echo "ERROR: Failed to source vars."; exit 1; }
source "$repo_folder"/helpers

cd "$JUJU_SOURCE_FOLDER" || exit 1
git checkout $JUJU_BRANCH
WHAT="jujud"
export DEBUG_JUJU=1
make $WHAT
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build $WHAT binaries, exiting.."
    exit 1
fi

# Build delve
if [ -d "$JUJU_SOURCE_FOLDER/delve" ]; then
    rm -rf "$JUJU_SOURCE_FOLDER/delve.old"
    mv "$JUJU_SOURCE_FOLDER/delve" "$JUJU_SOURCE_FOLDER/delve.old"
fi

git clone https://github.com/go-delve/delve.git  "$JUJU_SOURCE_FOLDER/delve"
cd "$JUJU_SOURCE_FOLDER/delve" || exit 1

make build
cp "$JUJU_SOURCE_FOLDER/delve/dlv" "$GOPATH/bin"

ssh ubuntu@${BASTION_IP} 'mkdir -p juju-binaries'
rsync --checksum --delete -avz "$GOPATH/bin/" ubuntu@"${BASTION_IP}":~/juju-binaries/
rsync --checksum --delete -Cravz "$repo_folder/" ubuntu@"${BASTION_IP}":"$repo_name"/

echo "INFO: Successfully built and synced juju binaries to bastion node"
echo "INFO: Now you can run ~/${repo_name}/02-setup-cluster.sh from your bastion node"

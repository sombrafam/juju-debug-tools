#!/bin/bash -ex

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars
source "$repo_folder"/helpers

cd "$KUBERNETES_FOLDER" || exit 1
WHAT="cmd/kubelet cmd/kubectl cmd/kube-proxy cmd/kube-apiserver cmd/kube-controller-manager cmd/kube-scheduler"
make all DBG=1 WHAT="$WHAT"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build kubernetes binaries, exiting.."
    exit 1
fi

find "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/" -type f -name "*.org" -exec rm {} \;
rm -f "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/dlv-wrapper"

cp "$repo_folder/dlv-wrapper" "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/"
for i in $DEBUG_TARGETS; do
    echo "INFO: wrapping debug to $i"
    mv "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/$i" "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/$i.org"
    ln -rs "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/dlv-wrapper" "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/$i";
done

# Build delve
rm -rf "$KUBERNETES_FOLDER/delve"
git clone https://github.com/go-delve/delve.git  "$KUBERNETES_FOLDER/delve"
cd "$KUBERNETES_FOLDER/delve" || exit 1
export GOROOT=/snap/go/current/
make build
cp "$KUBERNETES_FOLDER/delve/dlv" "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/"

ssh ubuntu@${BASTION_IP} 'mkdir -p kubernetes-binaries '"$repo_name"
rsync --checksum --delete -avz "$repo_folder/" ubuntu@"${BASTION_IP}":"$repo_name"/
rsync --checksum --delete -avz "$KUBERNETES_FOLDER/_output/local/bin/linux/amd64/" ubuntu@${BASTION_IP}:kubernetes-binaries/

echo "INFO: Successfully built and synced kubernetes binaries to bastion node"


#!/bin/bash -ex

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars
source "$repo_folder"/helpers

KUBE_MASTER_APPS="kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet kubectl"
KUBE_MASTER_SERVICES="kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet"

KUBE_WORKER_APPS="kube-proxy kubelet kubectl"
KUBE_WORKER_SERVICES="kube-proxy kubelet"


juju status --format=short > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to get juju status, exiting.."
    exit 1
fi

# For Kubernetes Master
export KUBERNETES_DEBUG_LEVEL=4
# First save whatever there is there already
current_api_extra_args=$(juju config kubernetes-control-plane api-extra-args)
current_scheduler_extra_args=$(juju config kubernetes-control-plane scheduler-extra-args)
current_manager_extra_args=$(juju config kubernetes-control-plane controller-manager-extra-args)
current_proxy_extra_args=$(juju config kubernetes-control-plane proxy-extra-args)
updated_api_extra_args="${current_api_extra_args} v=$KUBERNETES_DEBUG_LEVEL"
updated_scheduler_extra_args="${current_scheduler_extra_args} v=$KUBERNETES_DEBUG_LEVEL"
updated_manager_extra_args="${current_manager_extra_args} v=$KUBERNETES_DEBUG_LEVEL"
updated_proxy_extra_args="${current_proxy_extra_args} v=$KUBERNETES_DEBUG_LEVEL"

juju config kubernetes-control-plane api-extra-args="${updated_api_extra_args}" \
 scheduler-extra-args="${updated_scheduler_extra_args}" \
 controller-manager-extra-args="${updated_manager_extra_args}" \
 proxy-extra-args="${updated_proxy_extra_args}"

# For Kubernetes Worker
# First save whatever there is there already
current_proxy_extra_args=$(juju config kubernetes-worker proxy-extra-args)
current_kubelet_extra_args=$(juju config kubernetes-worker kubelet-extra-args)
updated_proxy_extra_args="${current_proxy_extra_args} v=$KUBERNETES_DEBUG_LEVEL"
updated_kubelet_extra_args="${current_kubelet_extra_args} v=$KUBERNETES_DEBUG_LEVEL"

juju config kubernetes-worker kubelet-extra-args="${updated_kubelet_extra_args}" \
proxy-extra-args="${updated_proxy_extra_args}"

for node in $(get_control_nodes); do
    # setup ssh keys
    juju ssh "$node" "ssh-import-id-lp $LP_USER"
    # setup public ips on kubernetes workers/masters
    # fip=$(openstack floating ip list | grep None| cut -d"|" -f3 | head -1)
    # we need to use rsync since scp does not copy symlinks
    rsync --checksum --delete -avz /home/ubuntu/kubernetes-binaries/ ubuntu@"$node":~/kubernetes-binaries/
    for app in $KUBE_MASTER_APPS; do
        juju ssh "$node" "sudo mount --bind /home/ubuntu/kubernetes-binaries/$app /snap/$app/current/$app"
    done

    # restart kubernetes services
    for service in $KUBE_MASTER_SERVICES; do
        juju ssh "$node" "sudo systemctl restart snap.$service.daemon.service"
    done
done

for node in $(get_worker_nodes); do
    # setup ssh keys
    juju ssh "$node" "ssh-import-id-lp $LP_USER"
    # setup public ips on kubernetes workers/masters
    # fip=$(openstack floating ip list | grep None| cut -d"|" -f3 | head -1)
    # we need to use rsync since scp does not copy symlinks
    rsync --checksum --delete -avz /home/ubuntu/kubernetes-binaries/ ubuntu@"$node":~/kubernetes-binaries/
    for app in $KUBE_WORKER_APPS; do
        juju ssh "$node" "sudo mount --bind /home/ubuntu/kubernetes-binaries/$app /snap/$app/current/$app"
    done

    # restart kubernetes services
    for service in $KUBE_WORKER_SERVICES; do
        juju ssh "$node" "sudo systemctl restart snap.$service.daemon.service"
    done
done


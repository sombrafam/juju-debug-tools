# Juju debugging utilities

The set of scripts in this repository are designed to help debug and
troubleshoot Juju controllers. The scripts are designed to be run as described
bellow.

## Usage

1. Configure the variables on vars

2. Developer machine:

00-install-prereqs.sh: Install the necessary tools on the local machine.
01-compile-and-sync.sh: Compile the necessary binaries and sync them to the bastion/jump host.

3. Bastion/jump host:

02-setup-cluster-debug.sh: Set up the necessary environment on the bastion/jump host.

Kubernetes cluster nodes:
  - Remove fragment HA, so you fifth you like that seem thems long dic [id already doing   ov bash@ -
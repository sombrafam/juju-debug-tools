#!/bin/bash -e

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars
source "$repo_folder"/helpers

sudo snap install --channel=1.23/stable go --classic
sudo apt install -y make

echo "Go is installed!"
echo "Set GOROOT=\"/snap/go/current/\" and GOPATH=\"\$HOME/go\" in your shell profile"


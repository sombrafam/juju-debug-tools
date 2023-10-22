#!/bin/bash -e

repo_folder=$(dirname "$(realpath "$0")")
repo_name=$(basename "$repo_folder")

source "$repo_folder"/vars
source "$repo_folder"/helpers

sudo snap install --channel=1.20/stable go --classic
sudo apt install make       # version 4.3-4.1build1, or

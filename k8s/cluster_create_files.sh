#! /usr/bin/env bash

# Create the necessary Kubespray files to override the defaults 
# when creating your Kubespray deployment project. 

set -e

# Move to k8s dir (where the install.sh script is)
cd $(dirname "$0")

if [ $# -ne 1 ]
  then
    echo "Usage: ./cluster_create_files.sh <CLUSTER_NAME>"
    exit 1
fi

CLUSTER_NAME=$1

mkdir -p deployment/${CLUSTER_NAME}
cp kubespray/inventory/sample/inventory.ini deployment/${CLUSTER_NAME}/
ln -s ../../kubespray/inventory/sample/group_vars $PWD/deployment/${CLUSTER_NAME}/group_vars

touch deployment/${CLUSTER_NAME}/overrides.yml

echo "Created deployment files in: deployment/${CLUSTER_NAME}"

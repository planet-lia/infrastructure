
#! /usr/bin/env bash

# Remove node from a Kubernetes cluster deployment using the Kubespray Ansible playbook

set -e

# Move to k8s dir (where the install.sh script is)
cd $(dirname "$0")

if [ $# -ne 3 ]
  then
    echo "Usage: ./node_add.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY> <NODE>"
    exit 1
fi

CLUSTER_NAME=$1
SSH_PRIVATE_KEY=$2
NODE=$3

if [ ! -f $SSH_PRIVATE_KEY ]; then
    echo "SSH Private Key $SSH_PRIVATE_KEY not found"
    exit 1
else
    echo "Using SSH key: ${SSH_PRIVATE_KEY}"
fi

INVENTORY_FILE="./deployment/${CLUSTER_NAME}/inventory.ini"

if [ ! -f $INVENTORY_FILE ]; then
    echo "Inventory file not found in $INVENTORY_FILE"
    exit 1
fi

set -x
ansible-playbook -i ${INVENTORY_FILE} --become --become-user=root --private-key=${SSH_PRIVATE_KEY} kubespray/remove-node.yml -b -v --extra-vars "node=${NODE}"

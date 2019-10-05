#!/usr/bin/env bash

# Run the Kubespray deployment Ansible playbook to install the cluster

set -e

# Move to cluster dir (where the install.sh script is)
cd $(dirname "$0")

if [[ $# -ne 2 ]]; then
    echo "Usage: ./install.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY_PATH>"
    exit 1
fi

CLUSTER_NAME=$1
SSH_PRIVATE_KEY_PATH=$2

if [[ ! -f $SSH_PRIVATE_KEY_PATH ]]; then
    echo "SSH Private Key $SSH_PRIVATE_KEY_PATH not found"
    exit 1
else
    echo "Using SSH key: ${SSH_PRIVATE_KEY_PATH}"
fi

INVENTORY_FILE="./deployment/${CLUSTER_NAME}/inventory.ini"
OVERRIDE_FILE="./deployment/${CLUSTER_NAME}/overrides.yml"

if [[ ! -f $INVENTORY_FILE ]]; then
    echo "Inventory file not found in $INVENTORY_FILE"
    exit 1
fi

if [[ ! -f $OVERRIDE_FILE ]]; then
    echo "Override file not found in $OVERRIDE_FILE"
    exit 1
fi

set -x
ansible-playbook -i ${INVENTORY_FILE} --become --become-user=root --extra-vars=@${OVERRIDE_FILE} --private-key=${SSH_PRIVATE_KEY_PATH} kubespray/cluster.yml

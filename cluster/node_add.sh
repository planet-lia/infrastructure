#!/usr/bin/env bash

# Add node to a Kubernetes deployment using the Kubespray Ansible playbook

set -e

# Move to cluster dir (where the install.sh script is)
cd $(dirname "$0")

if [ $# -ne 2 ]
  then
    echo "Usage: ./node_add.sh <CLUSTER_NAME> <SSH_PRIVATE_KEY>"
    exit 1
fi

CLUSTER_NAME=$1
SSH_PRIVATE_KEY=$2

if [ ! -f $SSH_PRIVATE_KEY ]; then
    echo "SSH Private Key $SSH_PRIVATE_KEY not found"
    exit 1
else
    echo "Using SSH key: ${SSH_PRIVATE_KEY}"
fi

INVENTORY_FILE="./deployment/${CLUSTER_NAME}/inventory.ini"
OVERRIDE_FILE="./deployment/${CLUSTER_NAME}/overrides.yml"

if [ ! -f $INVENTORY_FILE ]; then
    echo "Inventory file not found in $INVENTORY_FILE"
    exit 1
fi

if [ ! -f $OVERRIDE_FILE ]; then
    echo "Override file not found in $OVERRIDE_FILE"
    exit 1
fi

set -x
ansible-playbook -i ${INVENTORY_FILE} --become --become-user=root --extra-vars=@${OVERRIDE_FILE} --private-key=${SSH_PRIVATE_KEY} kubespray/scale.yml
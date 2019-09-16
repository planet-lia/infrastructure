#! /usr/bin/env bash

# Turn's on the UFW firewall and configures it to allow everything (incl. SSH)
# except 6443 (Kubernetes API server) for incoming traffic.

set -e

if [ $# -ne 3 ]
  then
    echo "Usage: ./firewall.sh <CLUSTER_MASTER_NODE> <SSH_PRIVATE_KEY> <CLUSTER_SUBNET_CIDR>"
    exit 1
fi

CLUSTER_MASTER_NODE=$1
SSH_PRIVATE_KEY=$2
CLUSTER_SUBNET_CIDR=$3

if [ ! -f $SSH_PRIVATE_KEY ]; then
    echo "SSH Private Key ${SSH_PRIVATE_KEY} not found"
    exit 1
else
    echo "Using SSH key: ${SSH_PRIVATE_KEY}"
fi

SSH_CMD="ssh -i ${SSH_PRIVATE_KEY} ${CLUSTER_MASTER_NODE}"

set -x

$SSH_CMD sudo ufw default allow outgoing
$SSH_CMD sudo ufw default allow incoming
$SSH_CMD sudo ufw default allow routed
$SSH_CMD sudo ufw allow ssh
# This rule allows nodes from the cluster to reach the API Server
$SSH_CMD sudo ufw allow proto tcp from ${CLUSTER_SUBNET_CIDR} to any port 6443
$SSH_CMD sudo ufw deny 6443
$SSH_CMD sudo ufw enable

#!/usr/bin/env bash
set -e

# Move to cluster dir (where the install.sh script is)
cd $(dirname "$0")

if [[ $# -ne 2 ]]; then
  echo "Usage: ./get_k8s_config.sh <SSH_MASTER_HOSTNAME> <CONFIG_OUTPUT>"
  echo "e.g. ./get_k8s_config.sh ubuntu@master-node.example.com ~/.kube/example-prod.conf"
  exit 1
fi

SSH_HOST=$1
CONFIG_PATH=$2
CONFIG_FILENAME=$(basename "${CONFIG_PATH}")

set -x 
ssh ${SSH_HOST} sudo cp /etc/kubernetes/admin.conf "${CONFIG_FILENAME}"
ssh ${SSH_HOST} sudo chown ubuntu: "${CONFIG_FILENAME}"
scp ${SSH_HOST}:"~/${CONFIG_FILENAME}" "${CONFIG_PATH}.bak"
ssh ${SSH_HOST} rm "${CONFIG_FILENAME}"

set +x

sed 's/\(server: https:\/\/\).*\(:6443\)/\1127.0.0.1\2/' "${CONFIG_PATH}.bak" > "${CONFIG_PATH}"
rm "${CONFIG_PATH}.bak"

echo "K8s config copied successfully to: ${CONFIG_PATH}"

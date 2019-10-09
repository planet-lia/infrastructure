#!/usr/bin/env bash

# Dependencies:
# * argocd-cli
# * openssl

# Change the default admin password of Argo-CD. The default password
# is the name of the pod running argo-cd-server.
# Note: If the server is no longer on the initial pod it was deployed 
# onto, you will need to reset the admin password.
#
# https://argoproj.github.io/argo-cd/faq/#i-forgot-the-admin-password-how-do-i-reset-it
#
# TLDR;
#   1. From argocd/argo-cd--secret remove lines: `admin.password` and `admin.passwordMtime`
#   2. Kill the argo-cd-server-... pod
#   3. The name of the new pod is your newly reset admin password. You can change this by
#       running this script with the proper parameters.

set -e

if [[ $# -ne 2 ]] && [[ $# -ne 1 ]]; then
  echo "Usage: ./change_admin_password.sh <GRPC_ARGOCD_DOMAIN> [password]"
  echo "If password not set, a random password will be generated."
  exit 1
fi

GRPC_ARGOCD_DOMAIN=$1
PASSWORD=$2

if [[ $# -eq 1 ]]; then
    echo "Generating random password"

    # Random 42 character password comprised of characters that 
    # are allowed by base64 encoding a-zA-Z0-9+/=
    PASSWORD=$(openssl rand -base64 42)
fi

OLD_PASSWORD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)

argocd login ${GRPC_ARGOCD_DOMAIN} --username admin --password ${OLD_PASSWORD} --insecure
argocd account update-password --current-password ${OLD_PASSWORD} --new-password ${PASSWORD} --insecure

echo "Password has been changed to: ${PASSWORD}"
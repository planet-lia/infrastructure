#!/usr/bin/env bash

# Move to root dir
cd $(dirname "$0")
cd ..

if [ $# -ne 1 ]
  then
    echo "Usage: ./install_overlay.sh <OVERLAY>"
    echo "e.g. ./install_overlay.sh production"
    exit 1
fi

OVERLAY=$1
OVERLAY_PATH="./overlays/${OVERLAY}"
SECRETS_PATH="./secrets/${OVERLAY}"

echo "Applying overlay: ${OVERLAY_PATH}"

kubectl apply -k ${OVERLAY_PATH}
KUBECTL_EXIT_CODE=$?

while [ ${KUBECTL_EXIT_CODE} != 0 ]
do
    echo "kubectl apply was not successful, re-applying in 10 seconds..."
    sleep 10

    echo "Re-Applying overlay: ${OVERLAY_PATH}"
    kubectl apply -k ${OVERLAY_PATH}
    KUBECTL_EXIT_CODE=$?
done

echo "Applying post-install secrets: ${SECRETS_PATH}/post-install"

kubectl apply -R -f ./${SECRETS_PATH}/post-install

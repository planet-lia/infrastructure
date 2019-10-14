#!/usr/bin/env bash

# Generates the nginx-ingress.yaml file from Helm chart. To override the values
# simply edit the `helm_values.yaml` file. In order to change versions just change
# the version in `VERSION`

set -e
set -x

# Move to script's dir
cd $(dirname "$0")

helm repo update
helm fetch stable/nginx-ingress --untar --version $(cat VERSION)

cd nginx-ingress

helm template --name nginx-ingress --namespace nginx-ingress -f ../helm_values.yaml . > ../nginx-ingress.yaml

cd ../
rm -rf nginx-ingress

set +x
echo "Successfully generated nginx-ingress.yaml"

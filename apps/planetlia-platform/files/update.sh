#/usr/bin/env bash
set -e

cd $(dirname "$0")

set -x
wget --quiet -O pvc.yaml 'https://github.com/minio/minio/blob/master/docs/orchestration/kubernetes/minio-standalone-pvc.yaml?raw=true'
wget --quiet -O deployment.yaml 'https://github.com/minio/minio/blob/master/docs/orchestration/kubernetes/minio-standalone-deployment.yaml?raw=true'
wget --quiet -O service.yaml 'https://github.com/minio/minio/blob/master/docs/orchestration/kubernetes/minio-standalone-service.yaml?raw=true'
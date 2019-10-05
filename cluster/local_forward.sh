#!/usr/bin/env bash

# Use this script to forward your Kubernetes API Server traffic to the
# master node via SSH. This can be used to access the API Server through 
# the internet when blocking interfnet traffic reaching Kubernetes' API 
# Server. You of course need SSH internet access to the master node for
# this to work.

set -e

if [[ $# -eq 0 ]]; then
  echo "Usage: ./local_forward.sh <HOST> [port]"
  exit 1
fi

HOST=$1
PORT=${2:-6443} 

set -x
ssh -nNT -L ${PORT}:127.0.0.1:${PORT} $HOST

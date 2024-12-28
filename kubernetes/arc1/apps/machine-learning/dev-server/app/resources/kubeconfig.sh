#!/bin/bash

CLUSTER="arc1"
NAMESPACE="machine-learning"
NAME="ml-dev-server-kubectl-access"
SERVICEACCOUNT="/var/run/secrets/kubernetes.io/serviceaccount"
TOKEN="$(/bin/cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
CACERT="$(/bin/cat $SERVICEACCOUNT/ca.crt | base64 -w 0)"

cat << EOF > /config/kubeconfig
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CACERT
    server: https://kubernetes.default.svc
  name: $CLUSTER
contexts:
- context:
    cluster: $CLUSTER
    user: $NAME
  name: $NAMESPACE
current-context: $NAMESPACE
users:
- name: $NAME
  user:
    token: $TOKEN
EOF

export KUBECONFIG=/config/kubeconfig
kubectl config set-context --current --namespace=$NAMESPACE

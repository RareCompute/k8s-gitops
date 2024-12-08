#!/bin/bash
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
  name: arc1
contexts:
- context:
    cluster: arc1
    user: ml-kubectl-access
  name: machine-learning
current-context: machine-learning
users:
- name: ml-kubectl-access
  user:
    token: $TOKEN
EOF

export KUBECONFIG=/config/kubeconfig

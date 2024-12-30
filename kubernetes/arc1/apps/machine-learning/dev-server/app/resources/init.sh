#!/usr/bin/env bash

set -e

MINICONDA_PATH="/config/miniconda3"
KUBECTL_PATH="/config/.local/bin"

if [ ! -d $MINICONDA_PATH ]; then
  echo "No conda detected, installing..."
  mkdir $MINICONDA_PATH
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -u -p $MINICONDA_PATH
  chown -R $UID:$GID $MINICONDA_PATH
  chmod 755 $MINICONDA_PATH
  export PATH=$PATH:/config/miniconda3/bin
fi

if [ ! -d $KUBECTL_PATH ]; then
  mkdir -p $KUBECTL_PATH
fi

if [ ! -f $KUBECTL_PATH/kubectl ]; then
  echo "No kubectl detected, installing..."
  cd $KUBECTL_PATH
  curl -s -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chown $UID:$GID $KUBECTL_PATH/kubectl
  chmod 755 $KUBECTL_PATH/kubectl
  export PATH=$PATH:$KUBECTL_PATH
fi

echo "───────────────────────────────────────"
echo "Finished initializing"

#!/usr/bin/env bash

set -e

if [ ! -d /config/miniconda3 ]; then
  echo "No conda detected, installing..."
  mkdir /config/miniconda3
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -u -p /config/miniconda3
  chown -R $UID:$GID /config
  chmod 755 /config
  export PATH=$PATH:/config/miniconda3/bin
fi

echo "───────────────────────────────────────"
echo "Finished initializing"

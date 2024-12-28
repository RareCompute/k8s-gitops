#!/usr/bin/env bash

cd /config
if [ ! -f /config/.local/bin/env ]; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/0.5.6/install.sh | sh
  . /config/.local/bin/env

  echo "Creating virtual env..."
  uv venv --no-python-downloads /config/venv
fi

#if [ "${INSTALL_SCIENCE_PACKAGES:-false}" = "true" ]; then
#  if [ -d /config/venv ]; then
#    . /config/venv/bin/activate
#    uv pip install \
#      tensorflow torch torchvision torchaudio transformers \
#      numpy pandas matplotlib scikit-learn \
#      networkx tqdm pydot
#  fi
#fi

path_add "/config/venv/bin"
path_add "/config/.local/bin"
path_add "/config/miniconda3/bin"

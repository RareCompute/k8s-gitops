#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the package index
echo "Updating package index..."
apk update

# Install required packages
echo "Installing packages..."
apk add --no-cache \
    mandoc \
    less \
    htop \
    unzip \
    tree \
    vim \
    nano \
    wget \
    curl \
    rsync \
    socat \
    aria2 \
    restic \
    kubectl \
    tmux \
    git \
    jq \
    bat \
    ripgrep \
    ffmpeg \
    fzf

echo "All specified packages have been installed successfully."

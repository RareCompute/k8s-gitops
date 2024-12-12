#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update the package index
echo "Updating package index..."
apt update && apt upgrade -y

# Install required packages
echo "Installing packages..."
apt install -y bat fzf

echo "All specified packages have been installed successfully."

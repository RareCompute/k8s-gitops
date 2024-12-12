#!/usr/bin/env bash

set -e

chown -R $UID:$GID /config
chmod 755 /config

echo "───────────────────────────────────────"
echo "Finished initializing"

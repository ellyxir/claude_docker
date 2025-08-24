#!/usr/bin/env bash

set -e

echo "Starting Claude Code Sandbox..."

# Initialize network security (optional)
if [ "$ENABLE_FIREWALL" = "true" ] && [ -f /init-firewall.sh ]; then
    echo "Setting up network security..."
    /init-firewall.sh
fi

# Create workspace directory if it doesn't exist
mkdir -p /workspace

# Start nix-shell with all packages
cd /root
exec nix-shell --command "cd /workspace && bash"
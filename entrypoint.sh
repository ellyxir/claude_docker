#!/usr/bin/env bash

set -e

echo "Starting Claude Code Sandbox..."

# Fix DNS to use Google's DNS
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Create workspace directory if it doesn't exist
mkdir -p /workspace

# Start nix-shell with all packages first, then apply firewall
cd /root

if [ "$ENABLE_FIREWALL" = "true" ]; then
    # Run nix-shell but apply firewall after initialization
    exec nix-shell --command "
        echo 'Initializing environment...'
        # Fix DNS again in case it got overwritten
        echo 'nameserver 8.8.8.8' > /etc/resolv.conf
        echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
        if [ -f /init-firewall.sh ]; then
            echo 'Setting up network security...'
            /init-firewall.sh
        fi
        cd /workspace
        exec bash
    "
else
    exec nix-shell --command "cd /workspace && bash"
fi
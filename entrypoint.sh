#!/usr/bin/env bash

set -e

echo "Starting Claude Code Sandbox..."

# Fix DNS to use Google's DNS (as root)
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

# Create workspace directory and set ownership
mkdir -p /workspace
chown developer:developer /workspace

# Apply firewall if enabled (as root)
if [ "$ENABLE_FIREWALL" = "true" ]; then
    echo "Setting up network security..."
    /init-firewall.sh
    echo "Firewall configured. Switching to non-root user..."
fi

# Ensure developer can read resolv.conf
chmod 644 /etc/resolv.conf

# Switch to developer user and run nix-shell
# Set PATH directly since sourcing in su can be problematic
exec su developer -s /bin/bash -c 'export PATH=/home/developer/.nix-profile/bin:$PATH && cd /home/developer && exec nix-shell --run bash'
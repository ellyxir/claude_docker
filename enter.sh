#!/usr/bin/env bash

# Quick script to enter the Claude Code container as developer user

if docker ps | grep -q claude-code-sandbox; then
    echo "Entering Claude Code Sandbox as developer..."
    # Enter as developer user with proper environment
    docker-compose exec -u developer claude-sandbox bash -c '
        export PATH=/home/developer/.nix-profile/bin:$PATH
        export NIX_PATH=/home/developer/.nix-defexpr/channels
        source /home/developer/.nix-profile/etc/profile.d/nix.sh 2>/dev/null
        cd /home/developer
        exec nix-shell
    '
else
    echo "Container is not running. Starting it first..."
    docker-compose up -d
    echo "Waiting for container to initialize (this may take a minute)..."
    sleep 60
    echo "Entering Claude Code Sandbox as developer..."
    docker-compose exec -u developer claude-sandbox bash -c '
        export PATH=/home/developer/.nix-profile/bin:$PATH
        export NIX_PATH=/home/developer/.nix-defexpr/channels
        source /home/developer/.nix-profile/etc/profile.d/nix.sh 2>/dev/null
        cd /home/developer
        exec nix-shell
    '
fi

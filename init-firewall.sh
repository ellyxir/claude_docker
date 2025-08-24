#!/usr/bin/env bash

# Network security script for Claude Code container
# Based on Anthropic's devcontainer recommendations

set -e

echo "Initializing network security..."

# Check if running as root (needed for iptables)
if [ "$EUID" -ne 0 ]; then 
    echo "Note: Firewall rules require root. Skipping network restrictions."
    exit 0
fi

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Default policies: deny all
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS (needed for package installation)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow HTTPS for specific services (customize as needed)
# GitHub
iptables -A OUTPUT -p tcp -d github.com --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d api.github.com --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d raw.githubusercontent.com --dport 443 -j ACCEPT

# NPM registry
iptables -A OUTPUT -p tcp -d registry.npmjs.org --dport 443 -j ACCEPT

# Python Package Index
iptables -A OUTPUT -p tcp -d pypi.org --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d files.pythonhosted.org --dport 443 -j ACCEPT

# Rust crates
iptables -A OUTPUT -p tcp -d crates.io --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d static.crates.io --dport 443 -j ACCEPT

# Go modules
iptables -A OUTPUT -p tcp -d proxy.golang.org --dport 443 -j ACCEPT

# Elixir/Hex packages
iptables -A OUTPUT -p tcp -d hex.pm --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d repo.hex.pm --dport 443 -j ACCEPT

# Anthropic API
iptables -A OUTPUT -p tcp -d api.anthropic.com --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d claude.ai --dport 443 -j ACCEPT

# Nix/NixOS
iptables -A OUTPUT -p tcp -d cache.nixos.org --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d channels.nixos.org --dport 443 -j ACCEPT

# Allow HTTP/HTTPS to localhost (for local dev servers)
iptables -A OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -d 127.0.0.1 --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d 127.0.0.1 --dport 3000:9999 -j ACCEPT

# Log dropped packets (optional, for debugging)
# iptables -A OUTPUT -j LOG --log-prefix "DROPPED OUTPUT: "

echo "Network security initialized. Only whitelisted connections allowed."
echo ""
echo "Allowed services:"
echo "  - GitHub (github.com, api.github.com)"
echo "  - Package registries: NPM, PyPI, Crates.io, Go modules, Hex"
echo "  - Anthropic (api.anthropic.com, claude.ai)"
echo "  - NixOS (cache.nixos.org, channels.nixos.org)"
echo "  - Local development servers (localhost:3000-9999)"
echo ""
echo "To disable firewall, set ENABLE_FIREWALL=false in docker-compose.yml"
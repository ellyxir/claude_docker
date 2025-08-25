#!/usr/bin/env bash
# Helper script to enter nix-shell with Claude

# Source Nix profile if needed (now from developer's home)
[ -f /home/developer/.nix-profile/etc/profile.d/nix.sh ] && source /home/developer/.nix-profile/etc/profile.d/nix.sh

cd /home/developer
exec nix-shell
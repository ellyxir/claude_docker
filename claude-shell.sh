#!/usr/bin/env bash
# Helper script to enter nix-shell with Claude

cd /root
exec nix-shell --command "cd /workspace && bash"
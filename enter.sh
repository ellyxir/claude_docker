#!/usr/bin/env bash

# Quick script to enter the Claude Code container

if docker ps | grep -q claude-code-sandbox; then
    echo "Entering Claude Code Sandbox..."
    echo "(Loading Nix packages...)"
    docker-compose exec claude-sandbox bash
else
    echo "Container is not running. Starting it first..."
    docker-compose up -d
    echo "Waiting for container to start..."
    sleep 3
    echo "Entering Claude Code Sandbox..."
    docker-compose exec claude-sandbox bash
fi
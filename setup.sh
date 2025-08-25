#!/usr/bin/env bash

# Setup script for Claude Code Nix Docker Sandbox

set -e

echo "================================================"
echo "  Claude Code Nix Docker Sandbox Setup"
echo "================================================"
echo ""

# Create workspace directory if it doesn't exist
if [ ! -d "workspace" ]; then
    echo "Creating workspace directory..."
    mkdir -p workspace
    echo "✓ Workspace directory created"
fi

# Create claude-config directory for auth persistence
if [ ! -d "claude-config" ]; then
    echo "Creating claude-config directory..."
    mkdir -p claude-config
    echo "✓ Claude config directory created"
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo ""
echo "Building and starting container..."
echo "(First run will download packages - this takes a few minutes)"
echo ""

# Build and start the container
docker-compose up --build -d

# Wait for container to be ready
echo ""
echo "Waiting for container to start..."
sleep 3

# Check if container is running
if docker ps | grep -q claude-code-sandbox; then
    echo "✓ Container is running!"
    echo ""
    echo "================================================"
    echo "  Setup Complete!"
    echo "================================================"
    echo ""
    echo "To enter the container:"
    echo "  ./enter.sh"
    echo ""
    echo "Or manually:"
    echo "  docker-compose exec -u developer claude-sandbox bash"
    echo "  Then run: claude-shell"
    echo ""
    echo "First time setup:"
    echo "  1. Run: claude login"
    echo "  2. Copy URL to browser, authenticate"
    echo "  3. Paste code back to terminal"
    echo ""
    echo "Then run Claude Code:"
    echo "  claude --dangerously-skip-permissions"
    echo ""
else
    echo "❌ Container failed to start. Check logs:"
    echo "  docker-compose logs"
    exit 1
fi
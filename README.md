# Claude Code Nix Docker Sandbox (Simplified)

A Docker container using Nix package manager that provides a sandboxed environment for running Claude Code with the `--dangerously-skip-permissions` flag, giving it full system access within the isolated container.

## Features

- **Nix Package Manager**: All tools managed via Nix shell for reproducibility
- **Isolated Environment**: Full system access within container, host system protected
- **Pre-configured Development Tools**: Git, Node.js, Python, Rust, Go, Elixir, Deno, and more
- **Persistent Workspace**: Mount your local workspace directory
- **Claude Code Pre-installed**: From nixpkgs unstable channel
- **Resource Limits**: Configurable CPU and memory constraints

## Prerequisites

- Docker and Docker Compose installed
- Claude Code account (you'll authenticate via browser)

## Quick Start

1. **Clone or create the directory structure**:
```bash
git clone <this-repo> claude_docker
cd claude_docker
```

2. **Create a workspace directory**:
```bash
mkdir -p workspace
```

3. **Build and start the container**:
```bash
docker-compose up --build -d
```

4. **Enter the container**:
```bash
docker-compose exec claude-sandbox bash
```
This automatically enters a Nix shell with all packages available.

5. **Inside the container, authenticate Claude Code** (first time only):
```bash
claude login
# Copy the URL to your browser, authenticate, paste the code back
```

6. **Run Claude Code**:
```bash
claude --dangerously-skip-permissions
```

## File Structure

```
claude_docker/
├── Dockerfile               # Minimal Docker setup with Nix
├── home-shell.nix           # Nix shell configuration with all packages
├── docker-compose.yml       # Container orchestration
├── entrypoint.sh            # Container initialization script
├── init-firewall.sh         # Optional network security script
├── workspace/               # Mounted workspace directory (create this)
└── claude-config/           # Claude Code auth persistence (auto-created)
```

## Available Tools

The container includes all tools from your NixOS configuration:

### From Stable Channel (nixpkgs 25.05)
- **Core**: git, gh, curl, wget, vim, helix, ripgrep, fd, bat, jq, tmux, htop
- **Languages**: Node.js 20, Python 3.12, Rust 1.86, Go 1.24, Elixir
- **Dev Tools**: TypeScript, cargo, npm, yarn, pnpm
- **Media**: ffmpeg

### From Unstable Channel
- **claude**: The Claude Code CLI
- **code2prompt**: Code to prompt converter

### From Pinned Channel
- **deno**: Version 2.35 specifically

## How It Works

1. The container starts with a minimal Nix environment
2. When you enter the container, it loads `home-shell.nix`
3. This Nix shell provides all packages in an isolated environment
4. First run downloads all packages (takes a few minutes)
5. Subsequent runs use cached packages (much faster)

## Configuration

### Adjusting Resources

Edit `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '4'      # Maximum CPUs
      memory: 8G     # Maximum memory
```

### Adding/Removing Packages

Edit `home-shell.nix` and rebuild:

```nix
buildInputs = (with stablePkgs; [
  # Add your packages here
  postgresql
  redis
]) ++ ...
```

### Enabling Network Firewall

Set in `docker-compose.yml`:
```yaml
environment:
  - ENABLE_FIREWALL=true  # Restricts network access
```

## Managing the Container

```bash
# Start container
docker-compose up -d

# Enter container
docker-compose exec claude-sandbox bash

# View logs
docker-compose logs

# Stop container
docker-compose down

# Rebuild after changes
docker-compose up --build -d
```

## Troubleshooting

### Container exits immediately
Check logs: `docker-compose logs`

### Packages not available
The first run downloads packages. Wait for:
```
"All packages loaded via Nix shell!"
```

### Claude Code authentication
Authentication persists in `./claude-config/` directory between container restarts.

### Slow first start
First run downloads ~500MB of packages. Subsequent starts are much faster due to Nix store caching.

## Security Notes

- Container runs with `--dangerously-skip-permissions` flag (full access within container)
- Host system protected via Docker isolation
- Optional firewall restricts network to package repos only
- Credentials stored securely in mounted volume

## VS Code DevContainer Support (Untested)

This project includes a `.devcontainer/devcontainer.json` for VS Code users. **Note: This feature is untested but should work.**

1. Install the "Dev Containers" extension in VS Code
2. Open this folder in VS Code
3. Click "Reopen in Container" when prompted
4. VS Code will build and connect to the container automatically

The devcontainer configuration:
- Automatically installs helpful extensions (Nix, Python, Rust, Go, etc.)
- Mounts your Claude config for persistent authentication
- Forwards common development ports (3000, 4000, 5000, 8000, 8080, 8888)

## License

MIT

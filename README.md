# Claude Code Docker Sandbox with Nix

A secure Docker container that provides a sandboxed environment for running Claude Code with the `--dangerously-skip-permissions` flag. Uses Alpine Linux as the base with Nix package manager for reproducible development environments.

## Features

- **Alpine Linux Base**: Minimal 5MB base image with Nix package manager
- **Non-root Execution**: Runs as unprivileged `developer` user for security
- **Network Firewall**: Restricts external access to only essential domains (GitHub, npm, pypi, Anthropic)
- **Nix Package Manager**: All tools managed via Nix shell for reproducibility
- **Pre-configured Development Tools**: Git, Node.js, Python, Rust, Go, Elixir, Deno, and more
- **Persistent Workspace**: Mount your local workspace directory
- **Claude Code Pre-installed**: Version 1.0.80 from nixpkgs unstable channel
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
./enter.sh
```
This automatically enters as the `developer` user and loads the Nix shell with all packages.

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
├── Dockerfile               # Docker setup with Nix and base tools
├── home-shell.nix           # Nix shell configuration with all packages
├── docker-compose.yml       # Container orchestration
├── entrypoint.sh            # Container initialization script  
├── init-firewall.sh         # Network security script (ipset-based firewall)
├── enter.sh                 # Quick entry script for developer user
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
- **claude**: Claude Code CLI v1.0.80
- **code2prompt**: Code to prompt converter

### From Pinned Channel
- **deno**: Version 2.3.5 specifically

## How It Works

1. Container starts with Alpine Linux and sets up the firewall (if enabled)
2. Firewall restricts network to GitHub IP ranges and essential domains
3. Process switches to unprivileged `developer` user
4. When you enter, it loads the Nix shell with all development tools
5. First run downloads packages through the firewall (takes a few minutes)
6. Subsequent runs use cached packages (much faster)

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

### Network Firewall

The firewall is enabled by default (`ENABLE_FIREWALL=true` in `docker-compose.yml`). It uses ipset with iptables to restrict network access.

**Allowed networks/domains:**
- GitHub IP ranges (140.82.112.0/20, 192.30.252.0/22, 185.199.108.0/22, etc.)
- Package repositories (npmjs.org, pypi.org, cache.nixos.org, channels.nixos.org)
- Claude/Anthropic APIs (claude.ai, api.anthropic.com)

**Security features:**
- Runs as non-root `developer` user after firewall setup
- Developer user cannot modify firewall rules (no sudo access)
- DNS fixed to Google's servers (8.8.8.8, 8.8.4.4)

**To disable firewall:**
```yaml
environment:
  - ENABLE_FIREWALL=false  # Allows all network access
```

**Testing firewall:**
```bash
# Inside container - should work:
curl -I https://github.com

# Should timeout/fail:
curl -I https://cnn.com
```

## Managing the Container

```bash
# Start container
docker-compose up -d

# Enter container as developer
./enter.sh

# Or manually:
docker-compose exec -u developer claude-sandbox bash -c 'cd /home/developer && exec nix-shell'

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

- Container runs Claude with `--dangerously-skip-permissions` flag (full access within container)
- Host system protected via Docker isolation
- Runs as unprivileged `developer` user, not root
- Developer cannot modify firewall rules (no sudo access)
- Network firewall restricts external access to GitHub IP ranges and essential domains
- DNS configured to use Google's DNS servers (8.8.8.8, 8.8.4.4)
- Credentials stored in mounted volume at `/home/developer/.config/claude-code`

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

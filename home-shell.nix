# shell.nix - Provides all packages in a Nix shell environment
{ pkgs ? import <nixpkgs> {} }:

let
  # Import different nixpkgs channels exactly as your system config does
  deno235 = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/9276d3225945c544c6efab8210686bd7612a9115.tar.gz") { config.allowUnfree = true; };
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/a595dde4d0d31606e19dcec73db02279db59d201.tar.gz") { config.allowUnfree = true; };
  
  # Use pinned nixpkgs for stable packages
  stablePkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/b1b3291469652d5a2edb0becc4ef0246fff97a7c.tar.gz") { config.allowUnfree = true; };

in stablePkgs.mkShell {
  buildInputs = 
    # Stable packages list (from your configuration.nix)
    (with stablePkgs; [
      # Core utilities
      git
      openssh  # SSH client for git clone/push/pull
      gh
      delta
      curl
      wget
      vim
      helix
      tmux
      htop
      tree
      jq
      ripgrep
      fd
      bat
      glow
      marksman
      nil
      util-linux
      
      # Development tools
      nodejs_20
      typescript
      typescript-language-server
      elixir
      elixir-ls
      python312
      gcc
      gnumake
      cargo
      rustc
      go
      
      # Build tools
      nodePackages.npm
      nodePackages.pnpm
      yarn
      
      # Media tools
      ffmpeg
      
      # Container utilities (excluding docker since we're inside a container)
      
      # Shell and terminal
      zsh
      fish
      starship
      
      # Security tools
      iptables
      ipset
    ]) ++ 
    # Unstable packages
    (with unstable; [
      claude-code
      code2prompt
    ]) ++ 
    # Deno 2.35
    (with deno235; [
      deno
    ]);
  
  shellHook = ''
    echo "================================================"
    echo "  Claude Code Sandbox Environment (Nix Shell)  "
    echo "================================================"
    echo ""
    echo "All packages loaded via Nix shell!"
    echo ""
    echo "Available tools:"
    echo "  - Claude Code: $(claude --version 2>/dev/null || echo 'Run: claude login')"
    echo "  - Node.js: $(node --version)"
    echo "  - Python: $(python --version 2>&1 | head -n1)"
    echo "  - Deno: $(deno --version | head -n1)"
    echo "  - Rust: $(rustc --version)"
    echo "  - Go: $(go version)"
    echo ""
    echo "Run: claude --dangerously-skip-permissions"
    echo ""
  '';
}
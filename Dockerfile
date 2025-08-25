FROM alpine:latest

# Install essential packages including tools for Nix installation
RUN apk add --no-cache \
    bash \
    coreutils \
    curl \
    xz \
    git \
    sudo \
    shadow \
    iptables \
    ip6tables \
    ipset \
    bind-tools \
    gawk \
    ca-certificates

# Create non-root user 'developer' WITHOUT sudo access
RUN adduser -D -u 1000 -s /bin/bash developer

# Create /nix directory with proper ownership for developer
RUN mkdir -m 0755 /nix && chown developer /nix

# Switch to developer user to install Nix
USER developer
WORKDIR /home/developer

# Install Nix as developer user (single-user installation)
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# Set up Nix environment for developer
ENV PATH="/home/developer/.nix-profile/bin:${PATH}"
ENV NIX_PATH="/home/developer/.nix-defexpr/channels"

# Add Nix channels as developer
RUN source /home/developer/.nix-profile/etc/profile.d/nix.sh && \
    nix-channel --add https://github.com/NixOS/nixpkgs/archive/b1b3291469652d5a2edb0becc4ef0246fff97a7c.tar.gz nixpkgs && \
    nix-channel --add https://github.com/NixOS/nixpkgs/archive/a595dde4d0d31606e19dcec73db02279db59d201.tar.gz nixpkgs-unstable && \
    nix-channel --update

# Switch back to root for copying files and setting up firewall
USER root

# Copy shell.nix to both root and developer home directories
COPY home-shell.nix /root/shell.nix
COPY --chown=developer:developer home-shell.nix /home/developer/shell.nix

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY init-firewall.sh /init-firewall.sh
COPY claude-shell.sh /usr/local/bin/claude-shell

RUN chmod +x /entrypoint.sh /init-firewall.sh /usr/local/bin/claude-shell

# Create workspace directory
RUN mkdir -p /workspace && chown developer:developer /workspace

WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
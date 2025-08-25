FROM nixos/nix:latest

# Install basic necessities including iptables for firewall
RUN nix-channel --add https://github.com/NixOS/nixpkgs/archive/b1b3291469652d5a2edb0becc4ef0246fff97a7c.tar.gz nixpkgs && \
    nix-channel --add https://github.com/NixOS/nixpkgs/archive/a595dde4d0d31606e19dcec73db02279db59d201.tar.gz nixpkgs-unstable && \
    nix-channel --update && \
    nix-env -iA nixpkgs.bashInteractive nixpkgs.coreutils nixpkgs.iptables nixpkgs.ipset nixpkgs.dnsutils nixpkgs.curl nixpkgs.gawk

# Copy shell.nix to home directory
COPY home-shell.nix /root/shell.nix

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
COPY init-firewall.sh /init-firewall.sh

RUN chmod +x /entrypoint.sh /init-firewall.sh

# Create workspace directory
WORKDIR /workspace

ENTRYPOINT ["/entrypoint.sh"]
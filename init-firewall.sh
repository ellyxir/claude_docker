#!/usr/bin/env bash

# Working network security script using ipset
# Based on Anthropic's approach but simplified for our container

set -euo pipefail

echo "Initializing network security with ipset..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Note: Firewall rules require root. Skipping network restrictions."
    exit 0
fi

# Flush existing rules
iptables -F 2>/dev/null || true
iptables -X 2>/dev/null || true
iptables -t nat -F 2>/dev/null || true
iptables -t nat -X 2>/dev/null || true
ipset destroy allowed-domains 2>/dev/null || true

# Create ipset for allowed domains and networks  
ipset create allowed-domains hash:net

# Function to add domain to ipset
add_domain() {
    local domain=$1
    echo "  Adding $domain..."
    
    # Use dig with external DNS to resolve domain
    local ips=$(dig @8.8.8.8 +short "$domain" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
    
    if [ -z "$ips" ]; then
        # Fallback to nslookup with external DNS if dig fails
        ips=$(nslookup "$domain" 8.8.8.8 2>/dev/null | grep "Address:" | grep -v "#" | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
    fi
    
    if [ -z "$ips" ]; then
        echo "    Warning: Could not resolve $domain"
        return
    fi
    
    for ip in $ips; do
        ipset add allowed-domains "$ip" 2>/dev/null || true
    done
}

echo "Adding allowed networks and domains..."

# GitHub IP ranges (from https://api.github.com/meta)
# These are stable ranges that GitHub publishes
ipset add allowed-domains 140.82.112.0/20 2>/dev/null || true
ipset add allowed-domains 192.30.252.0/22 2>/dev/null || true  
ipset add allowed-domains 185.199.108.0/22 2>/dev/null || true
ipset add allowed-domains 143.55.64.0/20 2>/dev/null || true
ipset add allowed-domains 140.82.121.0/24 2>/dev/null || true

# Critical domains that need individual resolution
add_domain "registry.npmjs.org"
add_domain "cache.nixos.org"
add_domain "channels.nixos.org"
add_domain "pypi.org"
add_domain "files.pythonhosted.org"
add_domain "api.anthropic.com"
add_domain "claude.ai"

# Set up iptables rules
echo "Applying firewall rules..."

# Allow loopback first
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow HTTPS to whitelisted IPs
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed-domains dst -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -m set --match-set allowed-domains dst -j ACCEPT

# Allow SSH (port 22) to GitHub IPs for git operations
iptables -A OUTPUT -p tcp --dport 22 -m set --match-set allowed-domains dst -j ACCEPT

# Allow local development
iptables -A OUTPUT -p tcp -d 127.0.0.1 --dport 1:65535 -j ACCEPT

# Log dropped packets for debugging (limit to avoid spam)
iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "FIREWALL_DROPPED: " --log-level 4

# Default policies (set after rules are added)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

echo ""
echo "Firewall configured successfully!"
echo "Allowed $(ipset list allowed-domains | grep -c '^[0-9]' || echo 0) IP addresses"
echo ""
echo "Test with: curl -I https://github.com (should work)"
echo "Test with: curl -I https://cnn.com (should fail)"
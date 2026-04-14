#!/usr/bin/env bash
# Drop-by-default egress firewall with a hostname allowlist.
# Runs as root at container start. Re-run to refresh resolved IPs.
set -euo pipefail

# --- allowlist -----------------------------------------------------------------
# Keep this list short and documented. Each entry is a DNS name that will be
# resolved to A records and added to the `allowed` ipset.
ALLOWED_HOSTS=(
  # GitHub
  github.com
  api.github.com
  codeload.github.com
  objects.githubusercontent.com
  raw.githubusercontent.com
  gist.githubusercontent.com

  # npm (Claude Code + pi updates, neovim plugins that pull npm pkgs)
  registry.npmjs.org

  # PyPI
  pypi.org
  files.pythonhosted.org

  # Rust crates.io
  crates.io
  static.crates.io
  index.crates.io

  # Anthropic (Claude Code)
  api.anthropic.com
  statsig.anthropic.com

  # Mistral (pi provider)
  api.mistral.ai
  codestral.mistral.ai

  # opencode (pi default provider)
  opencode.ai
  api.opencode.ai

  # 1Password service-account API
  my.1password.com
  events.1password.com
)

# --- reset ---------------------------------------------------------------------
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
ipset destroy allowed 2>/dev/null || true
ipset create allowed hash:ip family inet hashsize 1024 maxelem 65536

# --- resolve hostnames into the ipset -----------------------------------------
for host in "${ALLOWED_HOSTS[@]}"; do
  # getent returns IPv4 A records via nsswitch; fall back to dig if installed.
  ips=$(getent ahostsv4 "$host" | awk '{print $1}' | sort -u)
  if [[ -z "$ips" ]]; then
    echo "WARN: could not resolve $host" >&2
    continue
  fi
  while read -r ip; do
    [[ -n "$ip" ]] && ipset add allowed "$ip" -exist
  done <<<"$ips"
done

# --- default policies ----------------------------------------------------------
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# established/related return traffic
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# DNS — required to resolve the allowlist itself on subsequent lookups.
# Container resolvers live at whatever /etc/resolv.conf points at; allow both
# UDP and TCP/53 to any destination (resolver IPs are private to the container).
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# allowlist: HTTPS only (443). Claude Code, pi, op, git+https, npm, pip, cargo
# all use HTTPS. No plain-HTTP escape hatch.
iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed dst -j ACCEPT

# git+ssh to github (optional — uncomment if you push via ssh)
# iptables -A OUTPUT -p tcp --dport 22 -m set --match-set allowed dst -j ACCEPT

# log+drop anything else (rate-limited so a runaway loop doesn't flood dmesg)
iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "FW-DROP-OUT: " --log-level 4
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

echo "Firewall initialized. Allowed hosts: ${#ALLOWED_HOSTS[@]}, resolved IPs: $(ipset list allowed | grep -c '^[0-9]')"

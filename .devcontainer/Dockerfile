FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG USERNAME=vscode

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
      zsh tmux git curl ca-certificates gnupg unzip \
      build-essential pkg-config \
      python3 python3-pip python3-venv pipx \
      iptables ipset dnsutils iproute2 \
      fd-find fzf bat ripgrep jq less man-db \
    && rm -rf /var/lib/apt/lists/*

# Ubuntu ships fd-find as `fdfind` and bat as `batcat`; alias to the names
# the user's zshrc/nvim configs expect.
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd \
 && ln -sf /usr/bin/batcat /usr/local/bin/bat

# Neovim — use the official appimage-extracted binary for a current version
RUN curl -fsSL -o /tmp/nvim.tar.gz \
      https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
 && tar -C /opt -xzf /tmp/nvim.tar.gz \
 && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
 && rm /tmp/nvim.tar.gz

# Node.js (for pi + Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# Rust toolchain — user-scoped install happens in post-create; only install
# rustup prerequisites here.

# 1Password CLI
RUN curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
      | gpg --dearmor -o /usr/share/keyrings/1password-archive-keyring.gpg \
 && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" \
      > /etc/apt/sources.list.d/1password.list \
 && apt-get update && apt-get install -y --no-install-recommends 1password-cli \
 && rm -rf /var/lib/apt/lists/*

# Global npm installs: pi + Claude Code
RUN npm install -g @mariozechner/pi-coding-agent @anthropic-ai/claude-code \
 && npm cache clean --force

# zoxide
RUN curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
      | bash -s -- --bin-dir /usr/local/bin

# Allow the firewall init to run with sudo without a password — it's the only
# privileged action the user performs, and it runs once at container start.
RUN echo "${USERNAME} ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
      > /etc/sudoers.d/init-firewall \
 && chmod 0440 /etc/sudoers.d/init-firewall

COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh

USER ${USERNAME}
SHELL ["/bin/zsh", "-c"]

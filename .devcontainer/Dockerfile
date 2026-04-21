FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG USERNAME=vscode

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
      zsh tmux git curl ca-certificates gnupg unzip \
      build-essential pkg-config \
      python3 python3-pip python3-venv pipx \
      fd-find fzf bat ripgrep jq less man-db \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd \
 && ln -sf /usr/bin/batcat /usr/local/bin/bat

# Neovim
ARG NVIM_VERSION=v0.10.1
RUN curl -fsSL -o /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz" \
 && tar -C /opt -xzf /tmp/nvim.tar.gz \
 && ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim \
 && rm /tmp/nvim.tar.gz

# Node.js (for pi + Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

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

USER ${USERNAME}

# Rust (user-scoped, at build time to avoid needing sh.rustup.rs in the firewall allowlist)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile minimal \
 && /home/${USERNAME}/.cargo/bin/rustup component add rust-analyzer clippy rustfmt

SHELL ["/bin/zsh", "-c"]

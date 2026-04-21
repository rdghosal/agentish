#!/usr/bin/env bash
# Runs once after the container is created, as the non-root user.
# Firewall is managed by the w3cj/devcontainer-features/firewall feature.
set -euo pipefail

# --- shell ---------------------------------------------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ln -sfn "$HOME/.config/zsh/.zshrc" "$HOME/.zshrc"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] ||
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] ||
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

sudo mkdir -p /opt/brew-shim/share/zsh-autosuggestions /opt/brew-shim/share/zsh-syntax-highlighting
sudo ln -sfn "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /opt/brew-shim/share/zsh-autosuggestions/zsh-autosuggestions.zsh
sudo ln -sfn "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /opt/brew-shim/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
sudo tee /usr/local/bin/brew >/dev/null <<'EOF'
#!/bin/sh
[ "$1" = "--prefix" ] && echo /opt/brew-shim && exit 0
echo "brew: only --prefix is shimmed in this container" >&2; exit 1
EOF
sudo chmod +x /usr/local/bin/brew

if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

# --- agent config symlinks -----------------------------------------------------
# Host symlinks in ~/.config/claude and ~/.config/pi/agent use absolute host
# paths (e.g. /Users/<you>/...). Rather than rewriting them (which would mutate
# the RW-mounted host files), recreate the host paths inside the container as
# symlinks to the real mount points. The existing symlinks then resolve as-is.
# HOST_HOME is injected via devcontainer.json containerEnv (${localEnv:HOME}).
sudo mkdir -p "$HOST_HOME/code"
sudo ln -sfn "$HOME/code/agentish" "$HOST_HOME/code/agentish"
sudo ln -sfn "$HOME/.agents" "$HOST_HOME/.agents"
sudo ln -sfn "$HOME/.config" "$HOST_HOME/.config"

# --- neovim -------------------------------------------------------------------
# ~/.config/nvim is mounted RO, but ~/.config itself is writable. Copy the
# config to a sibling dir so lazy.nvim can write lazy-lock.json and clone
# plugins at the pinned versions. NVIM_APPNAME tells nvim to use it.
if [[ ! -d "$HOME/.config/nvim-sandbox" ]]; then
  cp -r "$HOME/.config/nvim" "$HOME/.config/nvim-sandbox"
fi

# --- .zshenv ------------------------------------------------------------------
{
  if [[ -r "$HOME/.config/secrets/op-sa-token" ]]; then
    echo 'export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$HOME/.config/secrets/op-sa-token")"'
  fi
  echo 'export NVIM_APPNAME="nvim-sandbox"'
} >"$HOME/.zshenv"

# --- theme / plugin caches ----------------------------------------------------
# bat needs its theme cache built once per container; ~/.config/bat is RO but
# ~/.cache/bat is writable.
bat cache --build >/dev/null 2>&1 || true

# Install lazy.nvim plugins pinned to the versions in lazy-lock.json so the
# container matches the host nvim state (no surprise plugin upgrades).
NVIM_APPNAME=nvim-sandbox nvim --headless '+Lazy! restore' +qa || true

# Warm the git metadata for the mounted workspace. Docker Desktop bind mounts
# on macOS have cold first-access latency, so the initial oh-my-zsh prompt and
# fugitive/gitsigns detection often miss the repo until .git is cached.
# postCreateCommand runs with CWD = workspaceFolder, so $PWD is the repo root.
[[ -d .git ]] && git status >/dev/null 2>&1 || true

echo "post-create complete."

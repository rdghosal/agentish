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

# --- 1Password service-account token ------------------------------------------
if [[ -r "$HOME/.config/secrets/op-sa-token" ]]; then
  cat >"$HOME/.zshenv" <<'EOF'
[ -r "$HOME/.config/secrets/op-sa-token" ] && \
  export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$HOME/.config/secrets/op-sa-token")"
EOF
fi

echo "post-create complete."

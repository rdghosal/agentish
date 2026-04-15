#!/usr/bin/env bash
# Runs once after the container is created, as the non-root user.
set -euo pipefail

# --- firewall ------------------------------------------------------------------
# Initialize the firewall now, and re-run on each `attach` via postStartCommand.
sudo /usr/local/bin/init-firewall.sh

# --- shell ---------------------------------------------------------------------
# oh-my-zsh — the user's .zshrc sources $ZSH/oh-my-zsh.sh and expects the
# `philips` theme + `git` plugin to exist, both of which ship with omz.
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Link the mounted .zshrc into $HOME so zsh picks it up on login.
ln -sfn "$HOME/.config/zsh/.zshrc" "$HOME/.zshrc"

# zsh-autosuggestions + zsh-syntax-highlighting — the zshrc sources them from
# `brew --prefix`, which doesn't exist here. Install into omz custom plugins
# and shim `brew` to point at their parent dir.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] ||
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] ||
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Fake `brew --prefix` so the existing zshrc's `source "$(brew --prefix)/share/..."`
# lines resolve to the omz plugin directory above.
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

# Default shell
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]]; then
  sudo chsh -s "$(command -v zsh)" "$USER"
fi

# Rust is installed in the image (see Dockerfile) so the runtime firewall
# doesn't need to allow sh.rustup.rs / static.rust-lang.org.

# --- 1Password service-account token ------------------------------------------
# The host binds ~/.config/secrets/op-sa-token RO; export it into the shell
# env so `op run` (invoked by the pi() wrapper in .zshrc) authenticates as
# the service account instead of looking for the desktop app.
if [[ -r "$HOME/.config/secrets/op-sa-token" ]]; then
  mkdir -p "$HOME/.config/zsh"
  cat >"$HOME/.zshenv" <<'EOF'
[ -r "$HOME/.config/secrets/op-sa-token" ] && \
  export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$HOME/.config/secrets/op-sa-token")"
EOF
fi

echo "post-create complete."

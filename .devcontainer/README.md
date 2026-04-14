# agentish sandbox devcontainer

A sandboxed Linux environment for running `pi` and `claude` with a
drop-by-default egress firewall. Host configs (`nvim`, `zsh`, `tmux`, `bat`,
`git`) are bind-mounted so the shell feels like home.

## Prerequisites

-  Docker (or any OCI runtime the `devcontainer` CLI supports)
-  [`@devcontainers/cli`](https://github.com/devcontainers/cli):
  `npm install -g @devcontainers/cli`
-  A 1Password **service account** token, saved at
  `~/.config/secrets/op-sa-token` with mode `600`:

  ```bash
  install -m 600 /dev/null ~/.config/secrets/op-sa-token
  $EDITOR ~/.config/secrets/op-sa-token   # paste the ops_... value
  ```

  Create the service account at `my.1password.com` → Developer Tools →
  Service Accounts. Grant read-only access to the vault holding
  `MISTRAL_API_KEY` and `OPENCODE_API_KEY`.

## Run

```bash
cd ~/code/agentish
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . zsh -l
```

Inside the container, `pi`, `claude`, `nvim`, and `tmux` are all on PATH.
The `pi()` shell function from your host `.zshrc` runs unchanged —
`op run` picks up `OP_SERVICE_ACCOUNT_TOKEN` and injects the same keys.

## Firewall

All egress is dropped by default. The allowlist lives in
[`init-firewall.sh`](./init-firewall.sh) and currently covers:

| Purpose           | Hosts |
|-------------------|-------|
| GitHub            | `github.com`, `api.github.com`, `codeload.github.com`, `objects.githubusercontent.com`, `raw.githubusercontent.com`, `gist.githubusercontent.com` |
| npm               | `registry.npmjs.org` |
| PyPI              | `pypi.org`, `files.pythonhosted.org` |
| crates.io         | `crates.io`, `static.crates.io`, `index.crates.io` |
| Anthropic         | `api.anthropic.com`, `statsig.anthropic.com` |
| Mistral           | `api.mistral.ai`, `codestral.mistral.ai` |
| opencode          | `opencode.ai`, `api.opencode.ai` |
| 1Password         | `my.1password.com`, `events.1password.com` |

To add a host: edit `ALLOWED_HOSTS` in `init-firewall.sh`, then either
rebuild (`devcontainer up --remove-existing-container --workspace-folder .`)
or re-run the firewall inside a running container:

```bash
sudo /usr/local/bin/init-firewall.sh
```

Blocked traffic is rate-limited-logged to dmesg with prefix `FW-DROP-OUT:`.
Inspect with `sudo dmesg | grep FW-DROP-OUT` when something breaks.

## Mounts

| Host path                    | Container path                        | Mode |
|------------------------------|---------------------------------------|------|
| `~/.config/nvim`             | `/home/vscode/.config/nvim`           | RO   |
| `~/.config/zsh`              | `/home/vscode/.config/zsh`            | RO   |
| `~/.config/bat`              | `/home/vscode/.config/bat`            | RO   |
| `~/.config/git`              | `/home/vscode/.config/git`            | RO   |
| `~/.config/tmux`             | `/home/vscode/.config/tmux`           | RO   |
| `~/.config/claude`           | `/home/vscode/.config/claude`         | RW   |
| `~/.config/pi`               | `/home/vscode/.config/pi`             | RW   |
| `~/.config/secrets`          | `/home/vscode/.config/secrets`        | RO   |

Agent state (`claude`, `pi`) is RW so sessions persist across rebuilds.

## Known gaps

-  `rustup component add` will fail — `static.rust-lang.org` isn't in the
  allowlist. Add it if you need extra toolchains.
-  Neovim plugins that fetch from hosts other than GitHub will fail on first
  `:Lazy sync`. Add the host to `ALLOWED_HOSTS`.
-  The `brew --prefix` shim in [`post-create.sh`](./post-create.sh) only
  handles `--prefix`; any other `brew` subcommand errors out.

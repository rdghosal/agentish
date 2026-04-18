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

Egress filtering is handled by the
[w3cj/devcontainer-features/firewall](https://github.com/w3cj/devcontainer-features/tree/main/src/firewall)
devcontainer feature. It uses `iptables` + `ipset` with Docker DNS
preservation, Docker network detection, config integrity checking,
and optional verbose block notifications.

### Enabled allowlists

| Feature flag       | What it allows                                               |
| ------------------ | ------------------------------------------------------------ |
| `claudeCode`       | Anthropic API + static IPs, Sentry, npm, VS Code marketplace |
| `mistralApi`       | `api.mistral.ai`, `mistral.ai`                              |
| `githubDomains`    | `github.com`, `api.github.com`, `raw.githubusercontent.com`, `ghcr.io`, etc. |
| `githubIps`        | GitHub IP ranges (fetched at runtime from GitHub's API)      |
| `npmRegistry`      | `registry.npmjs.org`                                         |
| `pypi`             | `pypi.org`, `files.pythonhosted.org`                         |
| `cratesIoRegistry` | `crates.io`, `static.crates.io`, `index.crates.io`          |
| `ubuntuPackages`   | `archive.ubuntu.com`, `security.ubuntu.com`                  |

### Extra hosts (not covered by built-in flags)

Added via the `hosts` option:

- `opencode.ai`, `api.opencode.ai` — pi's default opencode provider
- `my.1password.com`, `events.1password.com` — 1Password service account API

### Verbose mode

With `verbose: true`, blocked connections show inline terminal
notifications with the resolved domain name. Inspect logs with:

```bash
sudo dmesg | grep FW-BLOCKED
cat /var/log/firewall-blocks.log
```

### Adding hosts

Edit the `hosts` field in `devcontainer.json`, then rebuild:

```bash
devcontainer up --remove-existing-container --workspace-folder .
```

Or re-init the firewall in a running container:

```bash
sudo /usr/local/bin/init-firewall.sh
```

## Mounts

| Host path          | Container path                  | Mode |
| ------------------ | ------------------------------- | ---- |
| `~/.config/nvim`   | `/home/vscode/.config/nvim`     | RO   |
| `~/.config/zsh`    | `/home/vscode/.config/zsh`      | RO   |
| `~/.config/bat`    | `/home/vscode/.config/bat`      | RO   |
| `~/.config/git`    | `/home/vscode/.config/git`      | RO   |
| `~/.config/tmux`   | `/home/vscode/.config/tmux`     | RO   |
| `~/.config/claude` | `/home/vscode/.config/claude`   | RW   |
| `~/.config/pi`     | `/home/vscode/.config/pi`       | RW   |
| `~/.config/secrets` | `/home/vscode/.config/secrets` | RO   |

Agent state (`claude`, `pi`) is RW so sessions persist across rebuilds.

## Known gaps

-  Stable Rust + `rust-analyzer`, `clippy`, `rustfmt` are baked in at
  build time. Adding other toolchains or components at runtime will fail —
  `static.rust-lang.org` isn't in the allowlist. Bake extras into the
  Dockerfile, or add the host.
-  Neovim plugins that fetch from hosts other than GitHub will fail on first
  `:Lazy sync`. Add the host to the `hosts` option.
-  The `brew --prefix` shim in [`post-create.sh`](./post-create.sh) only
  handles `--prefix`; any other `brew` subcommand errors out.

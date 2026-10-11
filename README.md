# Opencode Config

[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20wsl%20ubuntu-blue)](https://github.com/ixynrs/opencode-config-private)
[![Status](https://img.shields.io/badge/status-verified-green)](CHANGELOG.md)

Portable Opencode config for Windows and WSL Ubuntu. One command installs it. MIT licensed.

Repo: `https://github.com/ixynrs/opencode-config-private`

## Contents

- [Install](#install)
- [Verify](#verify)
- [Prerequisites](#prerequisites)
- [Full Steps](#full-steps)
- [Fork Guide](#fork-guide)
- [Sync](#sync)
- [Fix List](#fix-list)
- [Security](#security)
- [Windows](#windows)
- [License](#license)

## Install

Paste once in WSL Ubuntu:

```bash
curl -fsSL https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/install.sh | bash
```

The script clones this repo to `~/.config/opencode`. It installs Node 22 and `uv`. It installs node deps. It installs Playwright Chromium libs. Re-run is safe.

## Verify

```bash
opencode --version
bash ~/.config/opencode/scripts/check.sh
```

Pass means two facts. Version prints. Check ends with `0 fail`.

Then create your secret by hand:

```bash
nano ~/.config/opencode/service.json
chmod 600 ~/.config/opencode/service.json
```

The repo ships no live secret. See [Security](#security).

## Prerequisites

| Item | Min version | Check |
| --- | --- | --- |
| Ubuntu | 22.04 | `lsb_release -a` |
| git | any recent | `git --version` |
| curl | any recent | `curl --version` |
| Node | 22.x, auto-install | `node -v` |
| uvx | auto-install | `uvx --version` |
| Opencode | latest | `opencode --version` |

The installer adds Node and uvx if absent. Other rows must pass first.

## Full Steps

Use this path if you prefer to see each step.

Step 1: base tools.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl unzip ca-certificates build-essential
```

Step 2: clone.

```bash
mkdir -p ~/.config
test -d ~/.config/opencode && mv ~/.config/opencode ~/opencode-backup-$(date +%F-%H%M)
git clone https://github.com/ixynrs/opencode-config-private.git ~/.config/opencode
ls ~/.config/opencode
```

Step 3: install.

```bash
cd ~/.config/opencode
bash install.sh
```

Step 4: secret. Copy `service.json.example` to `service.json`. Paste password from vault. Set `chmod 600`.

Step 5: verify. Run [Verify](#verify). Confirm zero Windows paths:

```bash
grep -c "C:/" ~/.config/opencode/opencode.jsonc || echo "0 Windows paths - good"
```

SSH fans: add a key to GitHub, then run `git remote set-url origin git@github.com:ixynrs/opencode-config-private.git`.

## Fork Guide

Fork the repo. Point `REPO_URL` in your `install.sh` at your fork. Point the curl URL in your README at your raw `install.sh`. Never commit live secrets. Test with a fresh WSL run. Fresh run must end with `0 fail`.

## Sync

Edit on one host. Push. Pull on the other host.

```bash
cd ~/.config/opencode && git add -A && git commit -m "feat: describe change" && git pull --rebase && git push
```

```bash
cd ~/.config/opencode && git pull --rebase && bash scripts/check.sh
```

## Fix List

| Symptom | Fix |
| --- | --- |
| Git auth fails | Add SSH key, or use the `https://` URL |
| Node too old | See Fix 1 |
| `uvx` not found | See Fix 2 |
| Playwright fails | See Fix 3 |
| Permission denied | See Fix 4 |
| Config drift | See Fix 5 |

Fix 1: refresh Node.

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v
```

Fix 2: add `uv` to PATH.

```bash
export PATH="$HOME/.local/bin:$PATH"
uvx --version
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

Fix 3: install Chromium libs.

```bash
npx -y playwright install --with-deps chromium
```

Fix 4: restore exec bits.

```bash
chmod +x ~/.config/opencode/install.sh ~/.config/opencode/scripts/*.sh
```

Fix 5: pull and re-check.

```bash
cd ~/.config/opencode && git pull --rebase && bash scripts/check.sh
```

## Security

- Never commit `service.json`. Git ignores it by default.
- Keep passwords in a vault. Never paste them in chat or mail.
- Rotate a password if it ever leaves the vault.
- Scan history for leaks:

```bash
git log --all -p -S "password" -- service.json || echo "no leak found"
```

## Windows

- Path: `%USERPROFILE%\.config\opencode`.
- Use the repo directly in that path. No symlink need.
- `check.sh` runs in Git Bash. `opencode --version` runs in PowerShell.

## License

MIT. See [LICENSE](LICENSE). Copyright (c) 2026 ixynrs.

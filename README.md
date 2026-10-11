# Opencode Config

## Goal

You store portable Opencode config in this repo.
You restore the same config on Windows and WSL Ubuntu.
You run one command in WSL for full setup.

Repo URL: `https://github.com/ixynrs/opencode-config-private`

## Map

- `AGENTS.md`: global rules for all agents.
- `opencode.jsonc`: portable MCP and agent config. No `C:/` path.
- `cli.json`: theme and terminal prefs.
- `agents/`: global agents.
- `skills/`: global skills.
- `tools/`: helper scripts in TypeScript.
- `docs/`: design notes.
- `tests/`: contract tests.
- `install.sh`: public one-step installer. It clones the repo if absent, then calls `scripts/install.sh`.
- `scripts/install.sh`: full setup for WSL Ubuntu.
- `scripts/check.sh`: verify script for both OS.
- `service.json.example`: secret template. Real `service.json` stays local.
- `LICENSE`: MIT license text.

Warning: `service.json` holds a live password. Never push it. Git ignores it by default.

## One-Line Install For Fresh WSL Ubuntu

Copy this block once. Paste it in WSL Ubuntu.

```bash
curl -fsSL https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/install.sh | bash
```

What it does:

- Clones this repo to `~/.config/opencode` if absent.
- Updates the clone with `git pull` if present.
- Installs Node 22 LTS if node is absent or old.
- Installs `uv` for `uvx` if absent.
- Installs node deps from `package.json`.
- Installs Playwright Chromium OS libs.

Then create your secret by hand (see Step 5). Then verify (see Step 6).

## TL;DR With Manual Clone

Use this path if you prefer to see each step. No placeholders. Values are final.

```bash
# 0: Update base
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl unzip ca-certificates

# 1: Clone config
mkdir -p ~/.config
test -d ~/.config/opencode && mv ~/.config/opencode ~/opencode-backup-$(date +%F-%H%M)
git clone https://github.com/ixynrs/opencode-config-private.git ~/.config/opencode
cd ~/.config/opencode

# 2: Run installer
bash install.sh

# 3: Verify
node -v
uvx --version
opencode --version
bash scripts/check.sh
```

Expected result: `check.sh` prints `OK` for each item. `opencode --version` prints a version.

## Step By Step For WSL Ubuntu

### Step 1: Prove OS version

Copy and paste:

```bash
lsb_release -a
uname -a
echo $HOME
```

Check: Output shows Ubuntu 22.04 or 24.04. Home path prints.

### Step 2: Install base tools if absent

Copy and paste:

```bash
sudo apt update
sudo apt install -y git curl unzip ca-certificates build-essential
git --version
curl --version | head -n 1
```

Check: Both commands print versions.

### Step 3: Clone this repo to Linux config path

Copy and paste:

```bash
mkdir -p ~/.config
ls -la ~/.config/opencode || echo "no old config"
test -d ~/.config/opencode && mv ~/.config/opencode ~/opencode-backup-$(date +%F-%H%M) || true
git clone https://github.com/ixynrs/opencode-config-private.git ~/.config/opencode
ls -la ~/.config/opencode
```

Check: `ls` shows `opencode.jsonc`, `agents/`, `skills/`, `scripts/`, `install.sh`.

For SSH fans, switch remote after clone:

```bash
ssh-keygen -t ed25519 -C "wsl-ubuntu" -f ~/.ssh/id_ed25519 -N ""
cat ~/.ssh/id_ed25519.pub
# Add output key in GitHub: Settings > SSH keys > New key
ssh -T git@github.com
cd ~/.config/opencode
git remote set-url origin git@github.com:ixynrs/opencode-config-private.git
git pull
```

### Step 4: Run install script

Copy and paste:

```bash
cd ~/.config/opencode
bash install.sh
```

What the script does:

- Install Node 22 LTS if node is absent or old.
- Install `uv` for `uvx` if absent.
- Install node deps from `package.json`.
- Install Playwright Chromium OS libs.
- Set safe perms on config dir.

Check: `node -v` shows `v22.x`. `uvx --version` prints a version.

### Step 5: Restore secret by hand

The repo has no live secret. You create it from your vault.

Copy and paste:

```bash
ls -l ~/.config/opencode/service.json || echo "absent - this is normal on first run"
cat ~/.config/opencode/service.json.example
nano ~/.config/opencode/service.json
chmod 600 ~/.config/opencode/service.json
```

Paste password from vault into `nano`. Save. Exit.

Check: File exists. Perms show `600`. Git ignores it:

```bash
cd ~/.config/opencode
git status --short
git check-ignore -v service.json
```

Expected result: `git status` hides `service.json`. `check-ignore` prints a rule match.

### Step 6: Verify full run

Copy and paste:

```bash
opencode --version
bash ~/.config/opencode/scripts/check.sh
grep -c "C:/" ~/.config/opencode/opencode.jsonc || echo "0 Windows paths - good"
```

Expected result:

- `opencode --version` prints a version.
- `check.sh` ends with `0 fail`.
- Windows path count is `0`.

## Use Your Own Fork

You can fork this repo and keep your own config in public or private.

Steps:

- Fork on GitHub. Keep the same file layout.
- Edit `REPO_URL` at the top of your `install.sh`. Point it at your fork.
- Edit `opencode.jsonc`, `agents/`, `skills/` to taste.
- Never commit live secrets. Keep `service.json` ignored.
- Update the one-line URL in this README to your raw `install.sh` path.

Check: Fresh WSL run with your fork URL ends with `0 fail`.

## Daily Sync Between Windows And WSL

Rule: Edit on one host. Push. Pull on the other host.

On edit host:

```bash
cd ~/.config/opencode
git status --short
git diff
git add -A
git commit -m "feat: describe change here"
git pull --rebase
git push
```

On other host:

```bash
cd ~/.config/opencode
git pull --rebase
bash scripts/check.sh
```

## Fix List

### Fix 1: Git auth fails

```bash
ssh -T git@github.com
cat ~/.ssh/id_ed25519.pub
```

Add key to GitHub. Retry `git pull`.

HTTPS works with no key. Use the `https://` clone URL in that case.

### Fix 2: Node version old

```bash
node -v
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
node -v
```

### Fix 3: uvx not found after install

```bash
export PATH="$HOME/.local/bin:$PATH"
uvx --version
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Fix 4: Playwright browser fails

```bash
npx -y playwright install --with-deps chromium
npx -y @playwright/mcp --help | head -n 20
```

### Fix 5: Permission denied on script

```bash
chmod +x ~/.config/opencode/install.sh ~/.config/opencode/scripts/*.sh
bash ~/.config/opencode/install.sh
```

### Fix 6: Config drift

```bash
cd ~/.config/opencode
git status --short
git pull --rebase
bash scripts/check.sh
```

## Security Notes

- Never commit `service.json`.
- Store live passwords in a vault, not in chat or mail.
- Rotate a password if it ever leaves the vault.
- Confirm no secret in git history:

```bash
git log --all -p -S "password" -- service.json || echo "no leak found"
git check-ignore -v service.json
```

## Windows Notes

- Windows config path: `%USERPROFILE%\.config\opencode`.
- This repo lives directly in that path after first push.
- No symlink need on Windows. Use direct git repo.
- Same `check.sh` runs in Git Bash, but use `opencode --version` in PowerShell for quick check.

## License

MIT. See `LICENSE` for full text.

Copyright (c) 2026 ixynrs.

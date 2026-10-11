#!/usr/bin/env bash
# Public one-step installer for portable opencode config.
# Run inside a clone: bash install.sh
# Run from the web: curl -fsSL https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/install.sh | bash
# Re-run is safe. The script skips done steps.
set -euo pipefail

REPO_URL="https://github.com/ixynrs/opencode-config-private.git"
CONFIG_DIR="$HOME/.config/opencode"

# Case 1: run inside a clone of this repo.
if [ -f "scripts/install.sh" ] && [ -f "opencode.jsonc" ]; then
  echo "Run local install from current dir."
  bash scripts/install.sh
  exit 0
fi

# Case 2: config dir already holds a clone. Update it.
if [ -d "$CONFIG_DIR/.git" ]; then
  echo "Update current config in $CONFIG_DIR."
  cd "$CONFIG_DIR"
  git pull --rebase || true
  bash scripts/install.sh
  exit 0
fi

# Case 3: fresh setup. Clone, then install.
mkdir -p "$HOME/.config"
if [ -d "$CONFIG_DIR" ]; then
  mv "$CONFIG_DIR" "$HOME/opencode-backup-$(date +%F-%H%M)"
fi
git clone "$REPO_URL" "$CONFIG_DIR"
cd "$CONFIG_DIR"
bash scripts/install.sh

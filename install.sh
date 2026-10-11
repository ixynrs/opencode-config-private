#!/usr/bin/env bash
# Public one-step installer for portable opencode config.
# Ubuntu: curl -fsSL https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/install.sh | bash
# Mac:    curl -fsSL https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/install.sh | bash
# Windows PowerShell: irm https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/scripts/install-windows.ps1 | iex
# Re-run is safe. The script skips done steps.
set -euo pipefail

REPO_URL="https://github.com/ixynrs/opencode-config-private.git"
CONFIG_DIR="$HOME/.config/opencode"
OS_NAME="$(uname -s)"

case "$OS_NAME" in
  Darwin) OS_ID="macos" ;;
  Linux) OS_ID="ubuntu" ;;
  MINGW*|MSYS*|CYGWIN*)
    echo "Git Bash on Windows cannot run apt setup."
    echo "Use PowerShell instead:"
    echo "  irm https://raw.githubusercontent.com/ixynrs/opencode-config-private/main/scripts/install-windows.ps1 | iex"
    exit 1
    ;;
  *)
    echo "Unknown OS: $OS_NAME. See README for manual steps."
    exit 1
    ;;
esac
echo "OS: $OS_ID"

run_setup() {
  if [ "$OS_ID" = "macos" ]; then
    bash scripts/install-macos.sh
  else
    if ! command -v apt >/dev/null 2>&1; then
      echo "No apt found. This path needs Ubuntu or WSL Ubuntu."
      exit 1
    fi
    bash scripts/install-ubuntu.sh
  fi
}

# Case 1: run inside a clone of this repo.
if [ -f "scripts/install-macos.sh" ] && [ -f "opencode.jsonc" ]; then
  echo "Run local install from current dir."
  run_setup
  exit 0
fi

# Case 2: config dir already holds a clone. Update it.
if [ -d "$CONFIG_DIR/.git" ]; then
  echo "Update current config in $CONFIG_DIR."
  cd "$CONFIG_DIR"
  git pull --rebase || true
  run_setup
  exit 0
fi

# Case 3: fresh setup. Clone, then install.
mkdir -p "$HOME/.config"
if [ -d "$CONFIG_DIR" ]; then
  mv "$CONFIG_DIR" "$HOME/opencode-backup-$(date +%F-%H%M)"
fi
git clone "$REPO_URL" "$CONFIG_DIR"
cd "$CONFIG_DIR"
run_setup

#!/usr/bin/env bash
# Setup portable opencode config on Mac (Intel and Apple Silicon).
# Re-run is safe. The script skips done steps.
set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
NODE_MAJOR_WANT="22"

echo "Check Apple Silicon"
if [ "$(uname -m)" != "arm64" ]; then
  echo "Intel Macs are out of scope. Use an Apple Silicon Mac."
  exit 1
fi

echo "[1/8] Check Xcode tools"
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Install Xcode command line tools. Follow the prompt, then re-run."
  xcode-select --install
  exit 1
fi

echo "[2/8] Check brew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew --version

echo "[3/8] Check Node"
NEED_NODE=0
if ! command -v node >/dev/null 2>&1; then
  NEED_NODE=1
else
  MAJOR=$(node -p "process.versions.node.split('.')[0]")
  if [ "$MAJOR" != "$NODE_MAJOR_WANT" ]; then
    echo "Found Node major $MAJOR, want $NODE_MAJOR_WANT. Upgrade."
    NEED_NODE=1
  fi
fi
if [ "$NEED_NODE" = "1" ]; then
  brew install node@22
  brew link --overwrite node@22 || true
fi
node -v
npm -v

echo "[4/8] Check uv for uvx"
if ! command -v uvx >/dev/null 2>&1; then
  brew install uv
fi
uvx --version

echo "[5/8] Check config dir"
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Clone first, then re-run this script."
  echo "git clone <your-fork-url> $CONFIG_DIR"
  exit 1
fi
cd "$CONFIG_DIR"

echo "[6/8] Install node deps"
if [ -f package-lock.json ]; then
  npm ci || npm install
elif [ -f package.json ]; then
  npm install
else
  echo "No package.json. Skip dep install."
fi

echo "[7/8] Install Playwright browser"
if command -v npx >/dev/null 2>&1; then
  npx -y playwright install chromium || true
fi

echo "[8/8] Set perms"
chmod 700 "$CONFIG_DIR" || true
if [ -f "$CONFIG_DIR/service.json" ]; then
  chmod 600 "$CONFIG_DIR/service.json"
fi

echo "Done. Run checks:"
echo "  opencode --version"
echo "  bash $CONFIG_DIR/scripts/check.sh"

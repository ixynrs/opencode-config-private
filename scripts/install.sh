#!/usr/bin/env bash
# Install portable opencode config on WSL Ubuntu.
# Re-run is safe. The script skips done steps.
set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
NODE_MAJOR_WANT="22"

echo "[1/7] Update apt base"
sudo apt update
sudo apt install -y git curl unzip ca-certificates build-essential

echo "[2/7] Check Node"
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
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  sudo apt install -y nodejs
fi
node -v
npm -v

echo "[3/7] Check uv for uvx"
if ! command -v uvx >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
if command -v uvx >/dev/null 2>&1; then
  uvx --version
else
  echo "Add uv to PATH:"
  echo 'export PATH="$HOME/.local/bin:$PATH"'
  export PATH="$HOME/.local/bin:$PATH"
  uvx --version
fi

echo "[4/7] Check config dir"
if [ ! -d "$CONFIG_DIR" ]; then
  echo "Clone first, then re-run this script."
  echo "git clone <your-private-url> $CONFIG_DIR"
  exit 1
fi
cd "$CONFIG_DIR"

echo "[5/7] Install node deps"
if [ -f package-lock.json ]; then
  npm ci || npm install
elif [ -f package.json ]; then
  npm install
else
  echo "No package.json. Skip dep install."
fi

echo "[6/7] Install Playwright OS libs"
if command -v npx >/dev/null 2>&1; then
  npx -y playwright install --with-deps chromium || npx -y playwright install chromium || true
fi

echo "[7/7] Set perms"
chmod 700 "$CONFIG_DIR" || true
if [ -f "$CONFIG_DIR/service.json" ]; then
  chmod 600 "$CONFIG_DIR/service.json"
fi

echo "Done. Run checks:"
echo "  opencode --version"
echo "  bash $CONFIG_DIR/scripts/check.sh"

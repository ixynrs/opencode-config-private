#!/usr/bin/env bash
# Check portable opencode config.
# Print OK or FAIL per item. Exit 0 if all pass.
set -uo pipefail

PASS=0
FAIL=0

check() {
  name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "OK: $name"
    PASS=$((PASS+1))
  else
    echo "FAIL: $name"
    FAIL=$((FAIL+1))
  fi
}

echo "Check base tools"
check "git" git --version
check "node" node -v
check "npm" npm -v
check "uvx" uvx --version
check "npx" npx --version

echo "Check config files"
test -f "$HOME/.config/opencode/opencode.jsonc" && echo "OK: opencode.jsonc" && PASS=$((PASS+1)) || { echo "FAIL: opencode.jsonc"; FAIL=$((FAIL+1)); }
test -f "$HOME/.config/opencode/cli.json" && echo "OK: cli.json" && PASS=$((PASS+1)) || { echo "FAIL: cli.json"; FAIL=$((FAIL+1)); }
test -f "$HOME/.config/opencode/AGENTS.md" && echo "OK: AGENTS.md" && PASS=$((PASS+1)) || { echo "FAIL: AGENTS.md"; FAIL=$((FAIL+1)); }

if [ -f "$HOME/.config/opencode/opencode.jsonc" ]; then
  if grep -q "C:/" "$HOME/.config/opencode/opencode.jsonc"; then
    echo "FAIL: Windows path C:/ found in opencode.jsonc"
    FAIL=$((FAIL+1))
  else
    echo "OK: no Windows path in opencode.jsonc"
    PASS=$((PASS+1))
  fi
fi

if [ -f "$HOME/.config/opencode/service.json" ]; then
  echo "OK: service.json exists (local secret, never commit)"
  PASS=$((PASS+1))
else
  echo "FAIL: service.json absent - copy from vault, see README"
  FAIL=$((FAIL+1))
fi

echo "Check opencode binary"
check "opencode" opencode --version

echo "Result: $PASS pass, $FAIL fail"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi

#!/usr/bin/env bash
# Back-compat alias. Ubuntu setup lives in install-ubuntu.sh.
set -euo pipefail
exec "$(dirname "$0")/install-ubuntu.sh"

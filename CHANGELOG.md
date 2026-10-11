# Changelog

## Unreleased

- Add 3-OS support. Ubuntu and WSL Ubuntu via apt. Mac Apple Silicon via brew. Windows 11 via winget in PowerShell 7.
- Add root `install.sh` OS router. It detects macOS, Linux, and Git Bash. It points Git Bash users at the PS1 script.
- Add `scripts/install-ubuntu.sh` with prior apt logic. Keep `scripts/install.sh` as back-compat alias.
- Add `scripts/install-macos.sh` with brew logic and Apple Silicon gate.
- Add `scripts/install-windows.ps1` with winget logic and PowerShell 7 gate.
- Add `scripts/check-windows.ps1` for native Windows verify.
- Rewrite `README.md` install top with 3 OS blocks.
- Add MIT `LICENSE` with copyright `ixynrs`.
- Add root `install.sh` for one-line public setup. It clones if absent, updates if present, then calls `scripts/install.sh`.
- Rewrite `README.md` for public use. No personal paths. Final URLs. Fork guide. License section.
- Mark `license` as MIT in `package.json`.
- Enforce LF ends for `install.sh` and `LICENSE`.

## v0.1.0-wsl-ready - 2026-10-11

- Add portable `opencode.jsonc` with no Windows absolute path.
- Add new `.gitignore` that blocks secrets, logs, and backups.
- Add `service.json.example` and ignore live `service.json`.
- Add `README.md` with one-block WSL Ubuntu restore.
- Add `scripts/install.sh` for just-work setup on Ubuntu.
- Add `scripts/check.sh` for verify on both OS.
- Keep `agents/`, `skills/`, `tools/`, `docs/`, `tests/` as baseline.

# Changelog

## Unreleased

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

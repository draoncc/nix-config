**Hosts**: each host is a `flake.nix` entry + `hosts/<name>/` + `home/cino/<name>.nix`, paired by `networking.hostName` (see `hosts/common/users/cino/default.nix`).

**Checks**: after changing a home config, run `nix flake check`; it builds `checks/` (e.g. Hyprland config verification). `just check` only evaluates and skips them. Hyprland config is Lua: start at the comment above `configType` in `home/cino/features/desktop/common/hyprland/default.nix`.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues for draoncc/nix-config via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Uses the five default triage labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

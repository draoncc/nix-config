**Hosts**: each host is an entry in `flake.nix`'s `nixosConfigurations`; `mkHost` pairs `hosts/<name>/` with `home/cino/<name>.nix` and sets `networking.hostName`.

**Checks**: `just check` after changing a config (builds `checks/`), plus `just hyprlock-check` for hyprlock; after a refactor, `just diff HOST` should print "unchanged"; after a switch, `just config-errors SINCE` lists errors from configs only parsed at runtime. A commit only parses the staged files and runs `just fmt-all`, re-staging what it formats; `just eval` then runs in the background, so after committing a config change run `flock .git/eval.lock true`: a `.git/eval-failed` file then means it failed, with the error in `.git/eval.log`. Hyprland config is Lua: start at the comment above `configType` in `home/cino/features/desktop/common/hyprland/default.nix`.

**Runtime testing** of Hyprland, hyprlock or hypridle: `scripts/nested-hyprland` runs a throwaway nested compositor, leaving the live tty sessions untouched. To see a theming or bar change before a switch: `just preview HOST`, then read the PNG it prints.

## Agent skills

### Issue tracker

Issues are tracked in GitHub Issues for draoncc/nix-config via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Uses the five default triage labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

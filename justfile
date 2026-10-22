alias fmt := format
alias fmt-all := format-all

host := `uname -a`
hostname := `hostname`

format FILE:
    nix fmt {{FILE}}

format-all:
    nix fmt

# Evaluate every config and build checks/ (the Hyprland config verifier)
check:
    nix flake check

# Evaluate only: fast, but skips checks/
eval:
    nix flake check --no-build

# Config errors daemons logged to the user journal this boot (or since SINCE,
# e.g. "10 min ago" after a switch). Catches what checks/ can't: configs
# only parsed at runtime (mako, hyprlock, swayosd, hyprpaper, ...).
config-errors SINCE="":
    #!/usr/bin/env bash
    since={{quote(SINCE)}}
    journalctl --user -b ${since:+--since "$since"} --no-pager -o short --no-hostname \
      | sed -E 's/^\S+ \S+ \S+ //; s/\[[0-9]+\]:/:/' \
      | grep -aiE 'config error|failed to parse|failed loading|parser error|invalid path|error opening file' \
      | sort | uniq -c | sort -rn | grep . || { echo "no config errors"; exit 0; }
    exit 1

# Load HOST's generated hyprlock.conf in a nested Hyprland (hyprlock has no
# verify flag, and parsing needs a display). Fails on config errors.
hyprlock-check HOST=hostname:
    #!/usr/bin/env bash
    set -eu
    hm=".#nixosConfigurations.{{HOST}}.config.home-manager.users.cino"
    conf=$(nix build --no-link --print-out-paths "$hm.xdg.configFile.\"hypr/hyprlock.conf\".source")
    hyprlock=$(nix build --no-link --print-out-paths "$hm.programs.hyprlock.package")/bin/hyprlock
    scripts/nested-hyprland -- bash -c '
      log=$(mktemp)
      "$1" --config "$2" >"$log" 2>&1 &
      for _ in $(seq 50); do scripts/nested-hyprland locked && break; sleep 0.1; done
      kill -USR1 $! 2>/dev/null
      trap "rm -f $log" EXIT
      if grep -a "Config error" "$log"; then exit 1; fi
      echo "hyprlock config ok"
    ' _ "$hyprlock" "$conf"

test:
    sudo nixos-rebuild --flake .#{{hostname}} test

build:
    sudo nixos-rebuild --flake .#{{hostname}} switch

upgrade:
    sudo nixos-rebuild --flake .#{{hostname}} switch --upgrade

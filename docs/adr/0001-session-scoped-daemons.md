# Daemons tied to one Hyprland session start from Hyprland, not systemd

Several Hyprland sessions can run at once, one per tty, but they all share a single systemd user manager. Each login runs home-manager's startup hook, which restarts `hyprland-session.target`. That moves every service under it to the newest session's `WAYLAND_DISPLAY`, and kills anything inside the old service's cgroup. So a daemon that serves one particular display starts from a `hl.on("hyprland.start", ...)` hook and lives in its compositor's session scope (`hypridle`, see `home/cino/features/desktop/common/hyprland/hypridle.nix`). Daemons that serve the user as a whole (pipewire, wireplumber, playerctld) stay systemd user services.

## Considered Options

- **Keep home-manager's systemd units** (its default for hypridle, hyprpaper, waybar, ...). Rejected: older sessions silently lose those daemons. A hyprlock spawned by hypridle was killed this way, leaving a tty locked with no lock client to accept input.
- **Run hyprlock outside hypridle's cgroup only** (`systemd-run --scope`). Kept as well, but on its own it still leaves older sessions without idle locking.

## Consequences

- Hook-started daemons get no `Restart=` and aren't restarted by home-manager when their config changes. A new login picks up the change.
- waybar, hyprpaper, swayosd, the portals and the clipboard daemons are still systemd units and still move to the newest session. Moving them follows this decision, one by one.

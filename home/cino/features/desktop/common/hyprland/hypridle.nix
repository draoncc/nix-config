{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ./lua.nix { inherit lib; }) hyprctlDispatch toLua;
  dpmsOn = hyprctlDispatch ''hl.dsp.dpms({ action = "on" })'';
  dpmsOff = hyprctlDispatch ''hl.dsp.dpms({ action = "off" })'';

  # Only count hyprlocks on our own display: with several Hyprland sessions
  # (one per tty) a locked session must not keep the others from locking.
  isLocked = toString (
    pkgs.writeShellScript "hyprlock-running" ''
      for pid in $(pgrep -xu "$UID" hyprlock); do
        grep -qzx "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" /proc/$pid/environ 2>/dev/null && exit 0
      done
      exit 1
    ''
  );
in
{
  # One hypridle per Hyprland session, started by the compositor rather than
  # as a systemd user service. The user manager is shared by every tty, and
  # each login restarts hyprland-session.target: a hypridle.service would be
  # moved to the newest session, leaving older ones with no idle locking.
  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function()
      hl.exec_cmd(${toLua (lib.getExe pkgs.hypridle)})
    end)
  '';

  services.hypridle = {
    enable = true;
    package = null; # No systemd unit; see above
    settings =
      let
        isDischarging = "grep Discharging /sys/class/power_supply/BAT{0,1}/status -q";
      in
      {
        general = {
          # Run hyprlock in its own scope so hypridle stopping (or being
          # stopped) never takes the lock client down with it: that leaves the
          # session locked with nothing to accept input.
          lock_cmd = "if ! ${isLocked}; then systemd-run --user --scope --collect --quiet ${lib.getExe config.programs.hyprlock.package} --grace 5; fi";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = dpmsOn;
          inhibit_sleep = 3; # Wait for lock before suspend
        };
        listener = [
          {
            timeout = 10;
            on-timeout = "brightnessctl --save";
            on-resume = "brightnessctl --restore";
          }
          {
            timeout = 30;
            on-timeout = "brightnessctl --device *:kbd_backlight --save set 0";
            on-resume = "brightnessctl --device *:kbd_backlight --restore";
          }
          {
            timeout = 50;
            on-timeout = "brightnessctl set 25%- -n 1";
          }
          {
            timeout = 110;
            on-timeout = "brightnessctl set 50%- -n 1";
          }
          {
            timeout = 120;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 140;
            on-timeout = dpmsOff;
            on-resume = dpmsOn;
          }

          # If already locked
          {
            timeout = 15;
            on-timeout = "if ${isLocked}; then brightnessctl set 75%- -n 1; fi";
          }
          {
            timeout = 20;
            on-timeout = "if ${isLocked}; then ${dpmsOff}; fi";
            on-resume = dpmsOn;
          }

          # If discharging
          {
            timeout = 900;
            on-timeout = "if ${isDischarging}; then systemctl suspend; fi";
          }
        ];
      };
  };
}

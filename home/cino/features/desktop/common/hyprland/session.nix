# A Hyprland session: the session the display manager offers, what tears it
# down, and the daemons each compositor starts for itself.
#
# Every session hook is a hyprland.start or hyprland.shutdown handler:
# home-manager's own (restart and stop hyprland-session.target) and the
# sessionDaemons one below. scripts/nested-hyprland --host drops exactly
# those events, so keep session behaviour behind them.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ./lua.nix { inherit lib; }) toLua;
  cfg = config.hyprland;

  # home-manager's shutdown hook stops hyprland-session.target (and with it
  # graphical-session.target) only when Hyprland shuts down cleanly. Wrap the
  # exported session so start-hyprland's return also tears the user session
  # down after a crash; otherwise our PartOf/WantedBy graphical-session.target
  # units would leak stale into the next login.
  hyprPackage = config.wayland.windowManager.hyprland.package;
  hyprSessionLauncher = pkgs.writeShellScript "start-hyprland-session" ''
    ${hyprPackage}/bin/start-hyprland "$@"
    ${pkgs.systemd}/bin/systemctl --user stop hyprland-session.target graphical-session.target
  '';
  hyprSession =
    pkgs.runCommandLocal "hyprland-session"
      {
        passthru.providedSessions = [ "hyprland" ];
      }
      ''
        mkdir -p $out/share/wayland-sessions
        substitute \
          ${hyprPackage}/share/wayland-sessions/hyprland.desktop \
          $out/share/wayland-sessions/hyprland.desktop \
          --replace-fail ${hyprPackage}/bin/start-hyprland ${hyprSessionLauncher}
      '';
in
{
  options.hyprland.sessionDaemons = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = lib.literalExpression "[ (lib.getExe pkgs.hypridle) ]";
    description = ''
      Commands each Hyprland compositor starts once, in its own session
      scope, rather than as systemd user services. Several sessions (one per
      tty) share one user manager, and each login restarts
      hyprland-session.target, so a unit serving one display would move to
      the newest session (docs/adr/0001-session-scoped-daemons.md).
    '';
  };

  config = {
    home.exportedSessionPackages = [ hyprSession ];

    wayland.windowManager.hyprland.extraConfig = lib.mkIf (cfg.sessionDaemons != [ ]) ''
      hl.on("hyprland.start", function()
      ${lib.concatMapStrings (cmd: "  hl.exec_cmd(${toLua cmd})\n") cfg.sessionDaemons}end)
    '';
  };
}

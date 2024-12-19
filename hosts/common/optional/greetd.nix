{ pkgs, lib, config, ... }:
let
  homeCfgs = config.home-manager.users;
  homePaths = lib.mapAttrsToList (n: v: "${v.home.path}/share") homeCfgs;
  extraDataPaths = lib.concatStringsSep ":" homePaths;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${extraDataPaths}"'';

  sway-kiosk = command: "${pkgs.sway}/bin/sway --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK"
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec '${vars} ${command} -l debug; ${pkgs.sway}/bin/swaymsg exit'
  ''}";

  hyprland = command: "${pkgs.hyprland}/bin/Hyprland --config ${pkgs.writeText "hyprland.conf" ''
    ${vars} ${command}; hyprctl dispatch exit
  ''}";

  cinoCfg = homeCfgs.cino;
in
{
  users.extraUsers.greeter.packages = [
    cinoCfg.gtk.theme.package
    cinoCfg.gtk.iconTheme.package
  ];

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        icon_theme_name = "ePapirus";
        theme_name = cinoCfg.gtk.theme.name;
      };
      background = {
        path = cinoCfg.wallpaper;
        fit = "Cover";
      };
    };
  };

  services.greetd = {
    enable = true;
    settings.default_session.command = hyprland (lib.getExe config.programs.regreet.package);
  };
}

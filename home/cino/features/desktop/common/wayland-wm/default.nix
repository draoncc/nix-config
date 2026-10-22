{ pkgs, ... }: {
  imports = [
    ./cliphist.nix
    ./clip-notify.nix
    # ./gammastep.nix
    ./mako.nix
    ./waybar.nix
    ./wofi.nix
    ./swayosd.nix
    # ./zathura.nix
  ];

  xdg.mimeApps.enable = true;
  home.packages = with pkgs; [
    wf-recorder
    wl-clipboard
    # wl-mirror
    # wl-mirror-pick
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    QT_QPA_PLATFORM = "wayland";
    LIBSEAT_BACKEND = "logind";
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
}

{ config, pkgs, ... }:

{
  # Theme and font come from Stylix
  stylix.targets.gtk.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = config.gtk.theme.name;
      "Net/IconThemeName" = config.gtk.iconTheme.name;
    };
  };

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}

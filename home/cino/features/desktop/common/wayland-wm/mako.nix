{ config, ... }:

let
  inherit (config.colorscheme) palette variant;
in
{
  services.mako = {
    enable = true;
    settings = {
      icon-path =
        if variant == "dark" then
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        else
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
      font = "${config.fontProfiles.regular.family} 12";
      padding = "10,20";
      anchor = "top-center";
      width = 400;
      height = 150;
      border-size = 2;
      default-timeout = 12000;
      background-color = "#${palette.base00}dd";
      border-color = "#${palette.base03}dd";
      text-color = "#${palette.base05}dd";
      layer = "overlay";
    };
  };
}

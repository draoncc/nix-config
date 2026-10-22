{ config, ... }:

{
  # Colours and font come from Stylix
  stylix.targets.mako.enable = true;

  services.mako = {
    enable = true;
    settings = {
      icon-path =
        if config.stylix.polarity == "dark" then
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Dark"
        else
          "${config.gtk.iconTheme.package}/share/icons/Papirus-Light";
      padding = "10,20";
      anchor = "top-center";
      width = 400;
      height = 150;
      border-size = 2;
      default-timeout = 12000;
      layer = "overlay";
    };
  };
}

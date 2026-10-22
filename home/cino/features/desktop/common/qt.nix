{ pkgs, ... }:

{
  qt = {
    enable = true;
    platformTheme = {
      name = "gtk3";
      package = [
        (pkgs.libsForQt5.qtstyleplugins.overrideAttrs (old: {
          # Make qtstyleplugins' gtk2 platform theme activate if QT_QPA_PLATFORMTHEME=gtk3
          patches = (old.patches or [ ]) ++ [ ./qtstyleplugins-gtk3-key.patch ];
        }))
        pkgs.qt5.qtbase
        pkgs.qt6.qtbase
      ];
    };
  };
}

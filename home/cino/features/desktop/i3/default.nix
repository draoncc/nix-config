{ pkgs, ... }:

let mod = "Mod1";
in {
  imports = [ ./wezterm ];

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
  };
}

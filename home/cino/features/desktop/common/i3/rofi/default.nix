{ pkgs, ... }:

{
  stylix.targets.rofi.enable = true;

  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-screenshot
    ];
    extraConfig = {
      modi = "window,run,ssh,drun,combi,calc";
      combi-modi = "window,drun";
    };
  };
}

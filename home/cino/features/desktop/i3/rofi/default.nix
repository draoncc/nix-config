{ pkgs, lib, ... }:

{
  home.file.".config/rofi/material.rasi".text =
    lib.strings.fileContents ./material.rasi;

  programs.rofi = {
    enable = true;
    plugins = with pkgs; [ rofi-calc rofi-emoji rofi-screenshot ];
    themePlugins."adi1090x-rofi".enable = true;
    extraConfig = {
      modi = "window,run,ssh,drun,combi,calc";
      combi-modi = "window,drun";
    };
  };
}

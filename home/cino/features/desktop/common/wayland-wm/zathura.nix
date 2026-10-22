{ config, ... }:

let
  inherit (config.stylix) fonts;
in
{
  # Colours come from Stylix
  stylix.targets.zathura.enable = true;

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      font = "${fonts.sansSerif.name} ${toString fonts.sizes.applications}";
      recolor = true;
    };
  };
}

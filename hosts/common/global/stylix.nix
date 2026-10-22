{ inputs, pkgs, ... }:

# Colours and fonts for every host and, through Stylix's home-manager
# auto-import, for cino's home. Targets are opt-in: see docs/adr/0002.
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";

    # Material Darker (base16) with Material Dark's extra base24 slots: darker
    # backgrounds (base10-11) and bright colours (base12-17). From
    # tinted-theming/schemes base16/material-darker.yaml and
    # base24/material-dark.yaml.
    base16Scheme = {
      system = "base24";
      name = "Material Darker";
      author = "Nate Peterson, FredHappyface";
      variant = "dark";
      palette = {
        base00 = "#212121";
        base01 = "#303030";
        base02 = "#353535";
        base03 = "#4A4A4A";
        base04 = "#B2CCD6";
        base05 = "#EEFFFF";
        base06 = "#EEFFFF";
        base07 = "#FFFFFF";
        base08 = "#F07178";
        base09 = "#F78C6C";
        base0A = "#FFCB6B";
        base0B = "#C3E88D";
        base0C = "#89DDFF";
        base0D = "#82AAFF";
        base0E = "#C792EA";
        base0F = "#FF5370";
        base10 = "#2c2c2c";
        base11 = "#161616";
        base12 = "#e83a3f";
        base13 = "#fee92e";
        base14 = "#7aba39";
        base15 = "#26bad1";
        base16 = "#53a4f3";
        base17 = "#a94dbb";
      };
    };

    fonts = rec {
      sansSerif = {
        name = "Luciole";
        package = pkgs.luciole;
      };
      serif = sansSerif;
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.nerd-fonts.fira-code;
      };
    };

    targets = {
      console.enable = true;
      fontconfig.enable = true;
      font-packages.enable = true;
      # Enables dconf, which home-manager's gtk target needs
      gtk.enable = true;
    };
  };
}

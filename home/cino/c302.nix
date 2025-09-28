{ inputs, ... }:

{
  imports = [
    ./global
    ./features/desktop
    ./features/desktop/optional/telegram.nix
  ];

  colorscheme = inputs.nix-colors.colorschemes.material;

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    x = 0;
    workspace = "1";
    primary = true;
  }];
}

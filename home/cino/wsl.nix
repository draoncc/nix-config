{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli/helix
  ];

  colorscheme = inputs.nix-colors.colorschemes.material;
}

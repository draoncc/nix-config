{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli/helix.nix
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

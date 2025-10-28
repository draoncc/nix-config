{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

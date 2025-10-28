{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli
    ./features/cli/optional/godot.nix
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

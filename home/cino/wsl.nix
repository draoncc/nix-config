{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli
    ./features/cli/optional/godot.nix
    ./features/lang
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli/common
    ./features/cli/optional/godot.nix
    ./features/cli/optional/gmailctl.nix
    ./features/lang
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

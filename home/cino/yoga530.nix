{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli/common
    ./features/cli/optional/godot.nix
    ./features/cli/optional/gmailctl.nix
    ./features/desktop/common
    ./features/desktop/optional/telegram.nix
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

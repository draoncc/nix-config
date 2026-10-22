{ inputs, ... }:

{
  imports = [
    ./global
    ./features/cli/common
    ./features/cli/optional/godot.nix
    ./features/cli/optional/gmailctl.nix
    ./features/cli/optional/android-tools.nix
    ./features/cli/optional/claude.nix
    ./features/lang
  ];

  colorscheme = inputs.nix-colors.colorschemes.material-darker;
}

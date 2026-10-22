{ ... }:

{
  imports = [
    ./global
    ./features/cli/common
    ./features/cli/optional/godot.nix
    ./features/cli/optional/gmailctl.nix
    ./features/cli/optional/android-tools.nix
    ./features/cli/optional/proton-pass-cli.nix
    ./features/cli/optional/claude.nix
    ./features/lang
    ./features/desktop/common
    ./features/desktop/optional/telegram.nix
  ];

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      workspace = "1";
      primary = true;
    }
  ];
}

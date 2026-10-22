{ ... }:

{
  imports = [
    ./global
    ./features/cli/common
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

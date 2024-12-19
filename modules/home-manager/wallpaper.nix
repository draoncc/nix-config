{ lib, ... }:

let inherit (lib) types mkOption;
in {
  options.wallpaper = mkOption {
    type = types.str; # TODO: make path
    default = "~/.background-image"; # TODO: fix impure
    description = ''
      Wallpaper path
    '';
  };
}

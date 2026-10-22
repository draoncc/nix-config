{
  pkgs ? import <nixpkgs> { },
}:
rec {
  luciole = pkgs.callPackage ./luciole.nix { };
  clip-notify = pkgs.callPackage ./clip-notify { };
}

{ pkgs ? import <nixpkgs> { } }: rec {
  luciole = pkgs.callPackage ./luciole.nix { };
}

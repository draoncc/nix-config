{ pkgs, inputs, ... }:

{
  imports = [
    ./zsh
    ./direnv.nix
    ./starship.nix
    ./git.nix
    ./github.nix
  ];

  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them

    jq # JSON pretty printer and manipulator
    silver-searcher # Search file contents

    nixd # Nix LSP
    nixfmt # Nix formatter

    ltex-ls # Spell checking LSP

    inputs.nh.packages.x86_64-linux.default # nixos-rebuild and home-manager cli wrapper
  ];
}

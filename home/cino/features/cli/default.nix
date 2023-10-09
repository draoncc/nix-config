{ pkgs, inputs, ... }:

{
  imports = [
    ./zsh.nix
    ./direnv.nix
    ./starship.nix
    ./git.nix
  ];

  home.packages = with pkgs; [
    comma # Install and run programs by sticking a , before them

    jq # JSON pretty printer and manipulator

    nil # Nix LSP
    nixfmt # Nix formatter

    ltex-ls # Spell checking LSP

    inputs.nh.packages.x86_64-linux.default # nixos-rebuild and home-manager cli wrapper
  ];
}

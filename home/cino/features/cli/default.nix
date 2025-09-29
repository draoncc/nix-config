{ pkgs, inputs, ... }:

{
  imports = [
    ./zsh
    ./helix.nix
    # ./nvim
    ./direnv.nix
    ./starship.nix
    ./git.nix
    ./github.nix
    ./nix-index.nix
  ];

  home.packages = with pkgs; [
    jq # JSON pretty printer and manipulator
    silver-searcher # Search file contents
    just # Handy way to save and run project-specific commands

    nixd # Nix LSP
    nixfmt # Nix formatter

    ltex-ls # Spell checking LSP

    inputs.nh.packages.x86_64-linux.default # nixos-rebuild and home-manager cli wrapper
  ];

  programs.pay-respects.enable = true;
}

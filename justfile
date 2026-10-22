alias fmt := format
alias fmt-all := format-all

host := `uname -a`
hostname := `hostname`

format FILE:
    nix fmt {{FILE}}

format-all:
    nix fmt

check:
    nix flake check --no-build

test:
    sudo nixos-rebuild --flake .#{{hostname}} test

build:
    sudo nixos-rebuild --flake .#{{hostname}} switch

upgrade:
    sudo nixos-rebuild --flake .#{{hostname}} switch --upgrade

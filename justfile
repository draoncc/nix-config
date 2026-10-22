alias fmt := format
alias fmt-all := format-all

host := `uname -a`
hostname := `hostname`

format FILE:
    nixfmt {{FILE}}

format-all:
    for file in $(find . -name '*.nix'); do nixfmt $file; done

check:
    nix flake check --no-build

test:
    sudo nixos-rebuild --flake .#{{hostname}} test

build:
    sudo nixos-rebuild --flake .#{{hostname}} switch

upgrade:
    sudo nixos-rebuild --flake .#{{hostname}} switch --upgrade

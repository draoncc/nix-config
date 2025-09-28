alias fmt := format
alias fmt-all := format-all

host := `uname -a`
hostname := `hostname`

format FILE:
    nixfmt {{FILE}}

format-all:
    for file in $(find . -name '*.nix'); do nixfmt $file; done

test:
    sudo nixos-rebuild --flake .#{{hostname}} test

build:
    sudo nixos-rebuild --flake .#{{hostname}} switch

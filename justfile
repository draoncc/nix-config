host := `uname -a`
hostname := `hostname`

fmt FILE:
    nixfmt {{FILE}}

fmt-all:
    for file in $(find . -name '*.nix'); do nixfmt $file; done

test:
    sudo nixos-rebuild --flake .#{{hostname}} test

build:
    sudo nixos-rebuild --flake .#{{hostname}} switch

{ config, ... }:

let inherit (config) colorscheme;
in {
  home.sessionVariables.COLORTERM = "truecolor";
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "custom-${colorscheme.slug}";

      editor = {
        color-modes = true;
        bufferline = "multiple";
        line-number = "relative";
        indent-guides.render = true;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };

    themes = import ./theme.nix { inherit colorscheme; };
  };
}

{ config, ... }:

let inherit (config) colorscheme;
in {
  home.sessionVariables.COLORTERM = "truecolor";
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "${builtins.replaceStrings ["-"] ["_"] colorscheme.slug}";

      editor = {
        color-modes = true;
        bufferline = "multiple";
        line-number = "relative";
        default-line-ending = "lf";
        indent-guides.render = true;
        cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
    };
  };
}

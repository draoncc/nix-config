{ config, pkgs, ... }:

let inherit (config) colorscheme;
in {
  home.sessionVariables.COLORTERM = "truecolor";
  home.packages = with pkgs; [ netcat-gnu ]; # godot language server
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

    languages = {
      language-server.godot = {
        command = "${pkgs.netcat-gnu}/bin/nc";
        args = [ "127.0.0.1" "6005"];
      };

      language = [{
        name = "gdscript";
        language-servers = [ "godot" ];
      }];
    };
  };
}

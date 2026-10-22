{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    extensions = with pkgs; [ gh-markdown-preview ];
    settings = {
      prompt = "enabled";
    };
  };
  programs.gh-dash.enable = true;

  home.persistence = {
    "/persist".files = [ ".config/gh/hosts.yml" ];
  };
}

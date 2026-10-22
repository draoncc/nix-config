{ pkgs, ... }:

{
  home.packages = with pkgs; [ google-chrome ];

  home.persistence."/persist" = {
    directories = [
      ".config/google-chrome"
    ];
  };
}

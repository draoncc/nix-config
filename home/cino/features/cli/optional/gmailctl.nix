{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gmailctl
    jsonnet-language-server # Language server
  ];
}

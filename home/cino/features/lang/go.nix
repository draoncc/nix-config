{ pkgs, ... }:

{
  home.packages = with pkgs; [
    go
    gopls # Language server
    gcc # Compiler
  ];
}

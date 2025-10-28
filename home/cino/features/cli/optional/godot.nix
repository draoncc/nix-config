{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gdtoolkit_4
  ];
}

{ pkgs, ... }:

{ users.users.cino.packages = with pkgs; [ google-chrome ]; }

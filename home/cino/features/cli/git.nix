{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = "Cino";
    userEmail = "14227820+draoncc@users.noreply.github.com";

    extraConfig = { init.defaultBranch = "main"; };
    lfs.enable = true;
    ignores = [ ".direnv" ];
  };
}

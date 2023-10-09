{ pkgs, ... }: 

{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = "Cino";
    userEmail = "draoncc@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
    ignores = [ ".direnv" ];
  };
}

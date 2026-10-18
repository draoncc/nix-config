{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    settings = {
      user = {
        name = "Cino";
        email = "14227820+draoncc@users.noreply.github.com";
      };

      init.defaultBranch = "main";
    };

    lfs.enable = true;
    ignores = [ ".direnv" ];
  };
}

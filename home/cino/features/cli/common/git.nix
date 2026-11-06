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
      push.autoSetupRemote = true;
    };

    lfs.enable = true;
    ignores = [ ".direnv" ];
  };
}

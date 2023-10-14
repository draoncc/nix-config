{ lib, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    enableAutosuggestions = true;

    shellAliases = {
      e = "$EDITOR";
      p = "gopass";
      ls = "LC_COLLATE=C ls --color=auto --group-directories-first";
      ll = "ls -l";
      la = "ll -a";
      tar-gz = "tar -xvzf";
    };

    initExtra = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./keybindings.zsh)
      (lib.strings.fileContents ./options.zsh)
      (lib.strings.fileContents ./functions.zsh)
    ];

    antidote = {
      enable = true;
      plugins = [
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-history-substring-search"
        "hlissner/zsh-autopair"
        "wfxr/formarks"
      ];
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "z" "git" "terraform" "thefuck" ];
    };
  };
}

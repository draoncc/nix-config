{ lib, config, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;

    dotDir = "${config.home.homeDirectory}/.config/zsh";
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    autosuggestion.enable = true;

    shellAliases = {
      p = "gopass";
      ls = "LC_COLLATE=C ls --color=auto --group-directories-first";
      ll = "ls -l";
      la = "ll -a";
      tar-gz = "tar -xvzf";
    };

    initContent = builtins.concatStringsSep "\n" [
      # Fix "widgets can only be called when zle is active" on jump
      # https://github.com/ohmyzsh/ohmyzsh/issues/3620#issuecomment-75435240
      ''
        TRAPWINCH() {
          zle && { zle reset-prompt; zle -R }
        }
        bindkey '^g' jump
      ''
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
      plugins = [ "z" "git" "gh" "terraform" ];
    };
  };
}

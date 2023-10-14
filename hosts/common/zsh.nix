{
  programs.zsh = { enable = true; };

  # Enable completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];
}

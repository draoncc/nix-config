{
  programs.zsh = {
    loginExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland &> /dev/null
      fi
    '';
    profileExtra = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec start-hyprland &> /dev/null
      fi
    '';
  };
}

{
  imports = [
    ./wezterm.nix
    ./gtk.nix
    ./qt.nix
    ./playerctl.nix
    ./google-chrome.nix
    ./proton-pass.nix

    ./hyprland
  ];

  xdg.portal.enable = true;
}

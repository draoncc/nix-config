{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Symlink the X server configuration under /etc/X11/xorg.conf
    # Without this, some commands fail: https://github.com/NixOS/nixpkgs/issues/19629#issuecomment-418238130
    exportConfiguration = true;

  #   # Enable minimal desktop/display manager setup to have a login screen
  #   # home-manager will take over after login in
  #   desktopManager.xterm.enable = false;
  #   displayManager.lightdm.enable = true;

  #   # Fixes lightdm failed to find session configuration default
  #   # Taken from: https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/11
  #   displayManager = {
  #     defaultSession = "none+fake";
  #     session = let
  #       fakeSession = {
  #         manage = "window";
  #         name = "fake";
  #         start = "";
  #       };
  #     in [ fakeSession ];
  #   };
  };
}

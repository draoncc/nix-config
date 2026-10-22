{ inputs, ... }:

{
  networking.hostName = "yoga530";

  imports = [
    inputs.nixos-facter-modules.nixosModules.facter

    ../common/global

    inputs.disko.nixosModules.disko
    ../common/disko-config.nix

    ../common/optional/ephemeral-btrfs.nix
    ../common/optional/networkmanager.nix
    ../common/optional/sound.nix
    # ../common/optional/regreet.nix
    ../common/optional/desktop.nix
    ../common/optional/touchpad.nix
    ../common/optional/backlight.nix
    ../common/optional/battery.nix
    ../common/optional/bluetooth.nix
    ../common/optional/docker.nix
    ../common/optional/quietboot.nix

    ../common/users/cino
  ];

  hardware.facter.reportPath = ./facter.json;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}

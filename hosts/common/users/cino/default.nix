{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Make users congruent to NixOS configuration.
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cino = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "audio"
      "docker"
      "git"
      "podman"
      "video"
      "wheel"
    ];
    hashedPassword = "$y$j9T$vDFlouCPsaL2VS1fO2iWT/$mf7JwgiP0d9mPWzfo.QyQ51QK9uCio4kOOG7tyil2n6";

    openssh.authorizedKeys.keys = lib.splitString "\n" (
      builtins.readFile ../../../../home/cino/ssh.pub
    );
  };

  home-manager.users.cino = import ../../../../home/cino/${config.networking.hostName}.nix;

  services.geoclue2.enable = true;
  security.pam.services = {
    swaylock = { };
  };
}

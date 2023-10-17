{ config, pkgs, ... }:

{
  # Make users congruent to NixOS configuration.
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cino = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "audio" ]; # Enable ‘sudo’ for the user.
    hashedPassword =
      "$6$zSPBGBvubSamHDYf$ElvGr0CmeCt7uO5YMxdLgizoX/nZr/PUyjpI1uZEGzkhLgDuVv6Sy/HRr9oC9mpqAjw.bIhOEc2mFQDIbc7Hw1";
    #   packages = with pkgs; [
    #     firefox
    #     tree
    #   ];
  };

  home-manager.users.cino =
    import ../../../../home/cino/${config.networking.hostName}.nix;

  services.geoclue2.enable = true;
}

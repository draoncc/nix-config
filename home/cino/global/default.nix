{ inputs, lib, config, outputs, ... }:

{
  imports = [
    inputs.nix-colors.homeManagerModule
    ./nix.nix
  ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;

  xdg.enable = true;

  home = {
    username = lib.mkDefault "cino";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "25.05";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = { FLAKE = "$HOME/Documents/NixConfig"; };
    preferXdgDirectories = true;

    persistence = {
      "/persist".directories = [
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
        "Code"
        ".local/bin"
        "nix-config"
      ];
    };
  };
}

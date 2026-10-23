{
  pkgs,
  lib,
  config,
  ...
}:
let
  xkb = config.services.xserver.xkb;
in
{
  # cage only reads its keymap from XKB_DEFAULT_* env vars, which the upstream
  # module's command doesn't set; services.xserver.xkb alone isn't enough.
  # Wrapping cage rather than prefixing the greetd command keeps that command
  # identical to upstream's, which Stylix's regreet target warns about.
  nixpkgs.overlays = [
    (_: prev: {
      cage = prev.symlinkJoin {
        name = "cage-xkb";
        paths = [ prev.cage ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cage \
            --set XKB_DEFAULT_LAYOUT ${lib.escapeShellArg xkb.layout} \
            --set XKB_DEFAULT_VARIANT ${lib.escapeShellArg xkb.variant} \
            --set XKB_DEFAULT_OPTIONS ${lib.escapeShellArg xkb.options}
        '';
        inherit (prev.cage) meta;
      };
    })
  ];

  stylix.targets.regreet.enable = true;

  services.displayManager.regreet = {
    enable = true;
    cageArgs = [
      "-d"
      "-s"
      "-m"
      "last"
    ];
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      package = pkgs.apple-cursor;
      name = "macOS";
    };
  };

  environment.persistence = {
    # Persist last user and last selected session
    "/persist".directories = [
      {
        directory = "/var/lib/regreet";
        user = "greeter";
        group = "greeter";
      }
    ];
  };
}

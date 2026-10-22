{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.displayManager.regreet;
  xkb = config.services.xserver.xkb;
in
{
  # cage only reads its keymap from XKB_DEFAULT_* env vars, which the upstream
  # module's command doesn't set; services.xserver.xkb alone isn't enough.
  services.greetd.settings.default_session.command = lib.concatStringsSep " " [
    "${pkgs.coreutils}/bin/env"
    (lib.escapeShellArgs [
      "XKB_DEFAULT_LAYOUT=${xkb.layout}"
      "XKB_DEFAULT_VARIANT=${xkb.variant}"
      "XKB_DEFAULT_OPTIONS=${xkb.options}"
    ])
    "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- ${lib.getExe cfg.package}"
  ];

  # Its "custom default_session.command may not work" warning is a string
  # compare against upstream's command; ours only prefixes the XKB env, and
  # regreet still reads the theme from its own config.
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

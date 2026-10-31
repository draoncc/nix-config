# Build-time checks for each host's generated home configs.
# Run with `just check` (`just eval` only evaluates, so it skips these).
{
  pkgs,
  lib,
  nixosConfigurations,
}:

let
  system = pkgs.stdenv.hostPlatform.system;

  hostsOnSystem = lib.filterAttrs (
    _: host: host.pkgs.stdenv.hostPlatform.system == system
  ) nixosConfigurations;

  # Hyprland's own config verifier, run on the hypr/ dir home-manager
  # generates. It catches an ignored config (Hyprland then writes a default
  # hyprland.lua) and config errors. Plugins are not loaded by
  # --verify-config, so plugin options and APIs go unchecked.
  hyprlandCheck =
    name: hm:
    let
      hyprland = hm.wayland.windowManager.hyprland.finalPackage;
    in
    pkgs.runCommandLocal "hyprland-${name}" { } ''
      export HOME=$TMPDIR/home
      export XDG_CONFIG_HOME=$HOME/.config XDG_RUNTIME_DIR=$TMPDIR/run
      mkdir -p $XDG_CONFIG_HOME $XDG_RUNTIME_DIR
      cp -rL ${hm.home-files}/.config/hypr $XDG_CONFIG_HOME/hypr
      chmod -R u+w $HOME

      before=$(ls $XDG_CONFIG_HOME/hypr)
      result=$(${hyprland}/bin/Hyprland --verify-config 2>&1 || true)
      after=$(ls $XDG_CONFIG_HOME/hypr)

      if [ "$before" != "$after" ]; then
        echo "Hyprland ignored the generated config and wrote its own:"
        echo "$result"
        exit 1
      fi
      if ! grep -q '^config ok' <<<"$result"; then
        echo "Hyprland config has errors:"
        sed -n '/Config parsing result/,$p' <<<"$result"
        exit 1
      fi
      touch $out
    '';

  # `hyprctl dispatch` takes a Lua expression (hl.dsp.*); the old
  # `hyprctl dispatch <dispatcher> <args>` form fails at runtime.
  hyprctlDispatchCheck =
    name: hm:
    pkgs.runCommandLocal "hyprctl-dispatch-${name}" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
      if grep -RnP 'hyprctl dispatch\s+(?!\\?['"'"'"]?hl\.)' ${hm.home-files}/; then
        echo "Found hyprctl dispatch calls in hyprlang syntax; use a Lua dispatcher, e.g. hyprctl dispatch 'hl.dsp.exit()'"
        exit 1
      fi
      touch $out
    '';

  # A CSS colour without its '#' (`color: 212121;`) is silently ignored.
  # Checks the CSS home-manager writes and the CSS files its configs
  # reference by store path (e.g. swayosd's stylePath in its unit).
  cssColorCheck =
    name: hm:
    pkgs.runCommandLocal "css-colors-${name}" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
      files=$(
        find -L ${hm.home-files} -name '*.css' -type f
        grep -RhoE '/nix/store/[^ "'"'"']+\.css' ${hm.home-files} | sort -u || true
      )
      if [ -n "$files" ] && grep -nHiE '(color|background)[[:space:]]*:[[:space:]]*[0-9a-f]{6}([0-9a-f]{2})?[[:space:]]*[;}!]' $files; then
        echo "CSS colours above are missing their '#'"
        exit 1
      fi
      touch $out
    '';

  # A package whose build differs from pkgs.<name> (programs.wofi.package
  # with a patch, hyprland from its input, ...) must be used everywhere: a
  # `''${pkgs.wofi}` beside it runs the stock build. Looks for the stock
  # store path of each such home.packages entry in the generated files.
  stockPackageCheck =
    name: hostPkgs: hm:
    let
      try =
        x:
        let
          r = builtins.tryEval x;
        in
        r.success && r.value;
      replaced = lib.unique (
        lib.concatMap (
          p:
          let
            n = p.pname or null;
          in
          lib.optional (
            n != null
            && try (hostPkgs ? ${n} && lib.isDerivation hostPkgs.${n} && hostPkgs.${n}.outPath != p.outPath)
          ) n
        ) hm.home.packages
      );
      # Only the path is needed, not the stock build itself.
      stockPath = n: builtins.unsafeDiscardStringContext hostPkgs.${n}.outPath;
    in
    pkgs.runCommandLocal "stock-packages-${name}" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
      ${lib.concatMapStrings (n: ''
        if grep -RlF ${stockPath n} ${hm.home-files}/; then
          echo "^ uses the stock ${n} (${stockPath n}); use the configured package, e.g. config.programs.${n}.package"
          fail=1
        fi
      '') replaced}
      [ -z "''${fail:-}" ] && touch $out
    '';

  # Each named theme must exist in its package: a typo'd or missing name
  # falls back to the toolkit default without an error.
  themeCheck =
    name: themes:
    pkgs.runCommandLocal "themes-${name}" { } ''
      ${lib.concatMapStrings (t: ''
        if [ ! -d ${t.package}/share/${t.dir}/${lib.escapeShellArg t.name} ]; then
          echo "${t.what}: no ${t.dir}/${t.name} in ${t.package}"
          fail=1
        fi
      '') themes}
      [ -z "''${fail:-}" ] && touch $out
    '';

  hmThemes =
    hm:
    lib.optionals hm.gtk.enable (
      lib.optional (hm.gtk.theme != null) (
        hm.gtk.theme
        // {
          what = "gtk.theme";
          dir = "themes";
        }
      )
      ++ lib.optional (hm.gtk.iconTheme != null) (
        hm.gtk.iconTheme
        // {
          what = "gtk.iconTheme";
          dir = "icons";
        }
      )
    )
    ++ lib.optional (hm.home.pointerCursor != null && hm.home.pointerCursor.enable) (
      hm.home.pointerCursor
      // {
        what = "home.pointerCursor";
        dir = "icons";
      }
    );

  hostThemes =
    host:
    let
      regreet = host.config.services.displayManager.regreet;
    in
    lib.optionals regreet.enable [
      (
        regreet.theme
        // {
          what = "regreet.theme";
          dir = "themes";
        }
      )
      (
        regreet.iconTheme
        // {
          what = "regreet.iconTheme";
          dir = "icons";
        }
      )
      (
        regreet.cursorTheme
        // {
          what = "regreet.cursorTheme";
          dir = "icons";
        }
      )
    ];

  src = ../.;

  # Every .nix file is imported, or parked behind a commented-out import.
  # flake.nix's mkHost imports each host's two modules by name, which the
  # script can't follow, so they are roots too.
  orphanCheck = pkgs.runCommandLocal "orphan-nix-files" { } ''
    ${pkgs.bash}/bin/bash ${./orphan-nix-files.sh} ${src} flake.nix ${
      lib.concatMapStringsSep " " (host: "hosts/${host}/default.nix home/cino/${host}.nix") (
        lib.attrNames nixosConfigurations
      )
    }
    touch $out
  '';

  # Hand-written theming reads Stylix through one binding per file
  # (docs/adr/0002): `palette = config.lib.stylix.colors;` and
  # `inherit (config.stylix) fonts;`.
  stylixIdiomCheck = pkgs.runCommandLocal "stylix-idiom" { nativeBuildInputs = [ pkgs.gnugrep ]; } ''
    if grep -rnE 'config\.lib\.stylix\.colors|config\.stylix\.fonts' --include='*.nix' ${src}/home ${src}/hosts \
      | grep -vE 'palette = config\.lib\.stylix\.colors;$|inherit \(config\.stylix\) fonts;$'; then
      echo "Read Stylix through 'palette = config.lib.stylix.colors;' and 'inherit (config.stylix) fonts;'"
      exit 1
    fi
    touch $out
  '';

  homeUsers = lib.concatMapAttrs (
    hostName: host:
    lib.mapAttrs' (user: hm: lib.nameValuePair "${hostName}-${user}" hm) host.config.home-manager.users
  ) hostsOnSystem;

  hyprlandUsers = lib.filterAttrs (_: hm: hm.wayland.windowManager.hyprland.enable) homeUsers;
in
{
  orphan-nix-files = orphanCheck;
  stylix-idiom = stylixIdiomCheck;
}
// lib.concatMapAttrs (name: hm: {
  "hyprland-${name}" = hyprlandCheck name hm;
  "hyprctl-dispatch-${name}" = hyprctlDispatchCheck name hm;
}) hyprlandUsers
// lib.concatMapAttrs (name: hm: {
  "css-colors-${name}" = cssColorCheck name hm;
  "themes-${name}" = themeCheck name (hmThemes hm);
}) homeUsers
// lib.mapAttrs' (
  hostName: host: lib.nameValuePair "themes-${hostName}" (themeCheck hostName (hostThemes host))
) hostsOnSystem
// lib.concatMapAttrs (
  hostName: host:
  lib.mapAttrs' (
    user: hm:
    lib.nameValuePair "stock-packages-${hostName}-${user}" (
      stockPackageCheck "${hostName}-${user}" host.pkgs hm
    )
  ) host.config.home-manager.users
) hostsOnSystem

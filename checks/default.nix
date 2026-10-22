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

  hyprlandUsers = lib.concatMapAttrs (
    hostName: host:
    lib.mapAttrs' (user: hm: lib.nameValuePair "${hostName}-${user}" hm) (
      lib.filterAttrs (_: hm: hm.wayland.windowManager.hyprland.enable) host.config.home-manager.users
    )
  ) hostsOnSystem;
in
lib.concatMapAttrs (name: hm: {
  "hyprland-${name}" = hyprlandCheck name hm;
  "hyprctl-dispatch-${name}" = hyprctlDispatchCheck name hm;
}) hyprlandUsers

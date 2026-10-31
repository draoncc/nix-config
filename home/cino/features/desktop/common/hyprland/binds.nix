# Hyprland's bind table. Features add entries to `hyprland.binds` (each
# file may contribute); this module renders them as `hl.bind` calls, in the
# main map or a submap, and fails evaluation when two entries in one map
# bind the same keys, which Hyprland itself accepts without a word.
{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  inherit (import ./lua.nix { inherit lib; })
    keys
    bind
    bindWith
    exec
    ;
  cfg = config.hyprland;

  keyString = b: keys b.mods b.key;
  dispatcher = b: if b.exec != null then exec b.exec else b.dispatcher;
  render =
    b:
    if b.options == { } then
      bind (keyString b) (dispatcher b)
    else
      bindWith (keyString b) (dispatcher b) b.options;

  # Modifier order doesn't matter to Hyprland, so it doesn't here either.
  # A key given once as a keysym and once as a keycode still goes unnoticed.
  chord =
    b:
    lib.optionalString (b.submap != null) "${b.submap}: "
    + keys (lib.sort lib.lessThan (lib.unique b.mods)) b.key;
  collisions = lib.filterAttrs (_: bs: lib.length bs > 1) (lib.groupBy chord cfg.binds);
  inSubmap = name: lib.filter (b: b.submap == name) cfg.binds;
  submaps = lib.unique (lib.filter (s: s != null) (map (b: b.submap) cfg.binds));
  repeatedMods = lib.filter (b: lib.unique b.mods != b.mods) cfg.binds;
  badActions = lib.filter (b: (b.dispatcher == null) == (b.exec == null)) cfg.binds;
in
{
  options.hyprland = {
    mod = mkOption {
      type = types.str;
      default = "ALT";
      description = "The modifier most binds start with.";
    };

    # Physical keys by their QWERTY label: binds that should stay where they
    # are on the keyboard whatever the layout (dvp moves the letters).
    # A plain key name such as "d" is a keysym, i.e. the dvp letter.
    qwerty = mkOption {
      readOnly = true;
      default = {
        q = "code:24";
        w = "code:25";
        e = "code:26";
        t = "code:28";
        u = "code:30";
        p = "code:33";
        s = "code:39";
        d = "code:40";
        f = "code:41";
        g = "code:42";
        semicolon = "code:47";
        apostrophe = "code:48";
        x = "code:53";
        v = "code:55";
        b = "code:56";
        minus = "code:20";
        equal = "code:21";
      };
    };

    binds = mkOption {
      default = [ ];
      type = types.listOf (
        types.submodule {
          options = {
            mods = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [
                "ALT"
                "SHIFT"
              ];
            };
            key = mkOption {
              type = types.str;
              example = "Return";
            };
            dispatcher = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "hl.dsp.window.close()";
              description = "Lua dispatcher expression. Set this or `exec`.";
            };
            exec = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Shell command to run. Set this or `dispatcher`.";
            };
            options = mkOption {
              type = types.attrsOf types.anything;
              default = { };
              example = {
                mouse = true;
              };
              description = "Bind options, passed as hl.bind's third argument.";
            };
            submap = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "passthrough";
              description = "Submap the bind belongs to; null for the main map.";
            };
          };
        }
      );
    };
  };

  config = {
    wayland.windowManager.hyprland = {
      settings.bind = map render (inSubmap null);
      submaps = lib.genAttrs submaps (name: {
        settings.bind = map render (inSubmap name);
      });
    };

    assertions = [
      {
        assertion = collisions == { };
        message =
          "hyprland.binds: keys bound more than once:\n"
          + lib.concatStrings (
            lib.mapAttrsToList (k: bs: "  ${k}: ${lib.concatMapStringsSep ", " dispatcher bs}\n") collisions
          );
      }
      {
        assertion = repeatedMods == [ ];
        message =
          "hyprland.binds: repeated modifiers (one would be dropped): "
          + lib.concatMapStringsSep ", " (b: toString (b.mods ++ [ b.key ])) repeatedMods;
      }
      {
        assertion = badActions == [ ];
        message =
          "hyprland.binds: set exactly one of `dispatcher` and `exec` for: "
          + lib.concatMapStringsSep ", " keyString badActions;
      }
    ];
  };
}

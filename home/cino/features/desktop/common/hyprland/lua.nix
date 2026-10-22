# Helpers for writing Hyprland's Lua config (configType = "lua") through
# home-manager's `settings`, where each attribute renders as `hl.<name>(...)`.
{ lib }:

let
  toLua = lib.generators.toLua { };
in
rec {
  inherit toLua;
  inline = lib.generators.mkLuaInline;

  # Key string from modifiers and a key, e.g. keys [ "ALT" "SHIFT" ] "code:24"
  # -> "ALT + SHIFT + code:24". Lua binds reject repeated keys, so duplicate
  # modifiers are collapsed (hyprlang silently did the same).
  keys = mods: key: lib.concatStringsSep " + " (lib.unique mods ++ [ key ]);

  # A `bind` entry: `dispatcher` is a Lua expression, e.g. "hl.dsp.exit()".
  bind = keyString: dispatcher: {
    _args = [
      keyString
      (inline dispatcher)
    ];
  };
  bindWith = keyString: dispatcher: opts: {
    _args = [
      keyString
      (inline dispatcher)
      opts
    ];
  };

  exec = cmd: "hl.dsp.exec_cmd(${toLua cmd})";

  # Shell command that runs a Lua dispatcher through hyprctl.
  hyprctlDispatch = dispatcher: "hyprctl dispatch ${lib.escapeShellArg dispatcher}";
}

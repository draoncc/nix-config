{ lib, ... }:
let
  inherit (import ./lua.nix { inherit lib; }) keys bind bindWith;

  workspaces = (map (n: "F${toString n}") (lib.range 1 12));
  # ++ (map toString (lib.range 0 9));
  mod = "ALT";
  keymaps = {
    e = "code:26";
    q = "code:24";
    s = "code:39";
    f = "code:41";
    minus = "code:20";
    equal = "code:21";
    g = "code:42";
    t = "code:28";
    apostrophe = "code:48";
    u = "code:30";
  };

  # Map keys to hyprland directions
  directions = {
    d = "l"; # left
    n = "r"; # right
    t = "u"; # up
    h = "d"; # down
  };

  directionBinds =
    mods: dispatcher:
    lib.mapAttrsToList (key: direction: bind (keys mods key) (dispatcher direction)) directions;
in
{
  wayland.windowManager.hyprland.settings = {
    bind =
      with keymaps;
      [
        (bindWith (keys [ mod ] "mouse:272") "hl.dsp.window.drag()" { mouse = true; })
        (bindWith (keys [ mod ] "mouse:273") "hl.dsp.window.resize()" { mouse = true; })

        (bind (keys [ mod "SHIFT" ] q) "hl.dsp.window.close()")
        (bind (keys [ mod "SHIFT" ] e) "hl.dsp.exit()")

        (bind (keys [ mod ] s) ''hl.dsp.layout("togglesplit")'')
        (bind (keys [ mod ] f) ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
        (bind (keys [ mod "SHIFT" ] f) ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
        (bind (keys [ mod "SHIFT" ] "space") "hl.dsp.window.float()")

        (bind (keys [ mod ] minus) ''hl.dsp.layout("splitratio -0.25")'')
        (bind (keys [ mod "SHIFT" ] minus) ''hl.dsp.layout("splitratio -0.3333333")'')

        (bind (keys [ mod ] equal) ''hl.dsp.layout("splitratio 0.25")'')
        (bind (keys [ mod "SHIFT" ] equal) ''hl.dsp.layout("splitratio 0.3333333")'')

        (bind (keys [ mod ] g) "hl.dsp.group.toggle()")
        (bind (keys [ mod ] t) "hl.dsp.group.lock()")
        (bind (keys [ mod ] apostrophe) "hl.dsp.group.next()")
        (bind (keys [ mod "SHIFT" ] apostrophe) "hl.dsp.group.prev()")

        (bind (keys [ mod ] u) "hl.dsp.workspace.toggle_special()")
        (bind (keys [ mod "SHIFT" ] u) ''hl.dsp.window.move({ workspace = "special" })'')
      ]
      ++
        # Change workspace
        (map (n: bind (keys [ mod ] n) ''hl.dsp.focus({ workspace = "name:${n}" })'') workspaces)
      ++
        # Move window to workspace
        (map (
          n: bind (keys [ mod "SHIFT" ] n) ''hl.dsp.window.move({ workspace = "name:${n}", follow = false })''
        ) workspaces)
      ++
        # Move focus
        (directionBinds [ mod ] (d: ''hl.dsp.focus({ direction = "${d}" })''))
      ++
        # Swap windows
        (directionBinds [ mod "SHIFT" ] (d: ''hl.dsp.window.swap({ direction = "${d}" })''))
      ++
        # Move windows
        (directionBinds [ mod "CONTROL" ] (
          d: ''hl.dsp.window.move({ direction = "${d}", group_aware = true })''
        ))
      ++
        # Move monitor focus
        (directionBinds [ mod "ALT" ] (d: ''hl.dsp.focus({ monitor = "${d}" })''))
      ++
        # Move workspace to other monitor
        (directionBinds [ mod "ALT" "SHIFT" ] (d: ''hl.dsp.workspace.move({ monitor = "${d}" })''));
  };
}

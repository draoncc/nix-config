{ config, lib, ... }:
let
  inherit (config.hyprland) mod qwerty;

  workspaces = (map (n: "F${toString n}") (lib.range 1 12));
  # ++ (map toString (lib.range 0 9));

  # Map keys to hyprland directions. These are keysyms: in dvp, d h t n sit
  # where QWERTY has h j k l.
  directions = {
    d = "l"; # left
    n = "r"; # right
    t = "u"; # up
    h = "d"; # down
  };

  bind = mods: key: dispatcher: { inherit mods key dispatcher; };
  directionBinds =
    mods: dispatcher:
    lib.mapAttrsToList (key: direction: bind mods key (dispatcher direction)) directions;
in
{
  hyprland.binds =
    with qwerty;
    [
      ((bind [ mod ] "mouse:272" "hl.dsp.window.drag()") // { options.mouse = true; })
      ((bind [ mod ] "mouse:273" "hl.dsp.window.resize()") // { options.mouse = true; })

      (bind [ mod "SHIFT" ] q "hl.dsp.window.close()")
      (bind [ mod "SHIFT" ] e "hl.dsp.exit()")

      (bind [ mod ] s ''hl.dsp.layout("togglesplit")'')
      (bind [ mod ] f ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
      (bind [ mod "SHIFT" ] f ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
      (bind [ mod "SHIFT" ] "space" "hl.dsp.window.float()")

      (bind [ mod ] minus ''hl.dsp.layout("splitratio -0.25")'')
      (bind [ mod "SHIFT" ] minus ''hl.dsp.layout("splitratio -0.3333333")'')

      (bind [ mod ] equal ''hl.dsp.layout("splitratio 0.25")'')
      (bind [ mod "SHIFT" ] equal ''hl.dsp.layout("splitratio 0.3333333")'')

      (bind [ mod ] g "hl.dsp.group.toggle()")
      (bind [ mod ] t "hl.dsp.group.lock()")
      (bind [ mod ] apostrophe "hl.dsp.group.next()")
      (bind [ mod "SHIFT" ] apostrophe "hl.dsp.group.prev()")

      (bind [ mod ] u "hl.dsp.workspace.toggle_special()")
      (bind [ mod "SHIFT" ] u ''hl.dsp.window.move({ workspace = "special" })'')
    ]
    ++
      # Change workspace
      (map (n: bind [ mod ] n ''hl.dsp.focus({ workspace = "name:${n}" })'') workspaces)
    ++
      # Move window to workspace
      (map (
        n: bind [ mod "SHIFT" ] n ''hl.dsp.window.move({ workspace = "name:${n}", follow = false })''
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
      (directionBinds [ mod "SUPER" ] (d: ''hl.dsp.focus({ monitor = "${d}" })''))
    ++
      # Move workspace to other monitor
      (directionBinds [ mod "SUPER" "SHIFT" ] (d: ''hl.dsp.workspace.move({ monitor = "${d}" })''));
}

{ lib, ... }:
let
  workspaces = (map toString (lib.range 0 9))
    ++ (map (n: "F${toString n}") (lib.range 1 12));
  mod = "SUPER";
  keymaps = {
    q = ";";
    s = "o";
    f = "u";
    minus = "!";
    equal = "#";
    g = "i";
    t = "y";
    apostrophe = "minus";
    u = "g";
  };

  # Map keys to hyprland directions
  directions = rec {
    left = "l";
    right = "r";
    up = "u";
    down = "d";
    d = left;
    n = right;
    t = up;
    h = down;
  };
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [ "${mod},mouse:272,movewindow" "${mod},mouse:273,resizewindow" ];

    bind = with keymaps;
      [
        "${mod}SHIFT,${q},killactive"
        "${mod}SHIFT,${e},exit"

        "${mod},${s},togglesplit"
        "${mod},${f},fullscreen,1"
        "${mod}SHIFT,${f},fullscreen,0"
        "${mod}SHIFT,space,togglefloating"

        "${mod},${minus},splitratio,-0.25"
        "${mod}SHIFT,${minus},splitratio,-0.3333333"

        "${mod},${equal},splitratio,0.25"
        "${mod}SHIFT,${equal},splitratio,0.3333333"

        "${mod},${g},togglegroup"
        "${mod},${t},lockactivegroup,toggle"
        "${mod},${apostrophe},changegroupactive,f"
        "${mod}SHIFT,${apostrophe},changegroupactive,b"

        "${mod},${u},togglespecialworkspace"
        "${mod}SHIFT,${u},movetoworkspace,special"
      ] ++
      # Change workspace
      (map (n: "${mod},${n},workspace,name:${n}") workspaces) ++
      # Move window to workspace
      (map (n: "${mod}SHIFT,${n},movetoworkspacesilent,name:${n}") workspaces)
      ++
      # Move focus
      (lib.mapAttrsToList
        (key: direction: "${mod},${key},movefocus,${direction}") directions) ++
      # Swap windows
      (lib.mapAttrsToList
        (key: direction: "${mod}SHIFT,${key},swapwindow,${direction}")
        directions) ++
      # Move windows
      (lib.mapAttrsToList
        (key: direction: "${mod}CONTROL,${key},movewindoworgroup,${direction}")
        directions) ++
      # Move monitor focus
      (lib.mapAttrsToList
        (key: direction: "${mod}ALT,${key},focusmonitor,${direction}")
        directions) ++
      # Move workspace to other monitor
      (lib.mapAttrsToList (key: direction:
        "${mod}ALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}")
        directions);
  };
}
